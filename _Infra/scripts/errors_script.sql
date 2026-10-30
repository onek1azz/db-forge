do $$
begin
	begin
		alter table parameter_types add column code varchar(50);
		alter table parameter_types add column short_name varchar(100);

		update parameter_types
		set code = v.code, short_name = v.short_name
		from (values
			(1, 'height', 'высота'),
			(2, 'temperature', 'температура'),
			(3, 'pressure', 'давление'),
			(4, 'wind_direction', 'направление ветра'),
			(5, 'wind_speed', 'скорость ветра'),
			(6, 'drift_range', 'дальность сноса пуль')
		) as v(id, code, short_name)
		where parameter_types.id = v.id;

		alter table parameter_types alter column code set not null;
		alter table parameter_types alter column short_name set not null;
		alter table parameter_types add constraint uq_parameter_types_code unique (code);

		comment on column parameter_types.code is 'Код параметра';
		comment on column parameter_types.short_name is 'Короткое название параметра';

		create table parameter_errors(
			id integer not null,
			code varchar(50) not null,
			description varchar(255) not null
		);
		create sequence seq_parameter_errors;
		alter table parameter_errors alter column id set default nextval('seq_parameter_errors');

		insert into parameter_errors (code, description) values
			('missing', 'значение не задано'),
			('range', 'значение вне допустимого диапазона'),
			('decimals', 'недопустимое число знаков после запятой');

		alter table parameter_errors add constraint pk_parameter_errors primary key (id);
		alter table parameter_errors add constraint uq_parameter_errors_code unique (code);

		comment on table parameter_errors is 'Справочник ошибок входных параметров';
		comment on column parameter_errors.id is 'Уникальный код';
		comment on column parameter_errors.code is 'Код ошибки';
		comment on column parameter_errors.description is 'Описание ошибки';

		create type parameter_list as (
			eq_type_id integer,
			height numeric,
			temperature numeric,
			pressure numeric,
			wind_direction numeric,
			wind_speed numeric,
			drift_range numeric
		);

		comment on type parameter_list is 'Список входных параметров';
		comment on column parameter_list.eq_type_id is 'Уникальный код типа оборудования';
		comment on column parameter_list.height is 'Высота метеопоста';
		comment on column parameter_list.temperature is 'Температура';
		comment on column parameter_list.pressure is 'Давление';
		comment on column parameter_list.wind_direction is 'Направление ветра';
		comment on column parameter_list.wind_speed is 'Скорость ветра';
		comment on column parameter_list.drift_range is 'Дальность сноса пуль';

	exception when others then
		raise notice 'ошибка в транзакции 1: %', sqlerrm;
		raise;
	end;

	commit;

	begin
		-- функция проверки списка параметров, вернет ошибки через точку с запятой, но если ошибок нет, вернет пустую строку
		create or replace function check_parameters(p_parameters parameter_list)
		returns text
		language plpgsql
		as $func$
		declare
			result text;
		begin
			select coalesce(string_agg(t.error_text, '; ' order by t.parameter_type_id), '')
			into result
			from (
				select
					pt.id as parameter_type_id,
					pt.short_name || ': ' ||
					case
						when v.val is null then
							(select description from parameter_errors where code = 'missing')
						when l.decimal_places is not null and v.val <> round(v.val, l.decimal_places) then
							(select description from parameter_errors where code = 'decimals')
							|| ' (допустимо: ' || cast(l.decimal_places as text) || ')'
						when v.val < l.min_value or v.val > l.max_value then
							(select description from parameter_errors where code = 'range')
							|| ' (от ' || cast(l.min_value as text) || ' до ' || cast(l.max_value as text) || ')'
					end as error_text
				from parameter_limits l
				inner join parameter_types pt on pt.id = l.parameter_type_id
				cross join lateral (
					select cast(to_jsonb(p_parameters) ->> pt.code as numeric) as val
				) v
				where l.eq_type_id = p_parameters.eq_type_id
			) t
			where t.error_text is not null;

			return result;
		end;
		$func$;

		comment on function check_parameters(parameter_list) is 'Проверка списка параметров, возвращает строку со списком ошибок';

	exception when others then
		raise notice 'ошибка в транзакции 2: %', sqlerrm;
		raise;
	end;

	commit;

	begin
		create or replace function meteo_ddchm(p_time timestamp)
		returns text
		language plpgsql
		as $func$
		begin
			return to_char(p_time, 'DD')
				|| to_char(p_time, 'HH24')
				|| cast(cast(floor(extract(minute from p_time) / 10) as integer) as text);
		end;
		$func$;

		create or replace function meteo_vvvv(p_height numeric)
		returns text
		language plpgsql
		as $func$
		begin
			return lpad(cast(cast(round(abs(p_height)) as integer) as text), 4, '0');
		end;
		$func$;

		create or replace function meteo_bbbtt(p_pressure numeric, p_temperature numeric)
		returns text
		language plpgsql
		as $func$
		declare
			v_pressure_deviation integer;
			v_temperature_deviation integer;
			v_bbb text;
			v_tt text;
		begin
			v_pressure_deviation := cast(round(p_pressure - get_meteo_constant('table_pressure')) as integer);
			v_temperature_deviation := cast(round(
				p_temperature
				+ interpolate(p_temperature, get_interpolation_points(p_temperature))
				- get_meteo_constant('table_temperature')
			) as integer);

			if v_pressure_deviation >= 0 then
				v_bbb := lpad(cast(v_pressure_deviation as text), 3, '0');
			else
				v_bbb := cast(cast(get_meteo_constant('negative_pressure_base') as integer) + abs(v_pressure_deviation) as text);
			end if;

			if v_temperature_deviation >= 0 then
				v_tt := lpad(cast(v_temperature_deviation as text), 2, '0');
			else
				v_tt := cast(cast(get_meteo_constant('negative_temperature_base') as integer) + abs(v_temperature_deviation) as text);
			end if;

			return v_bbb || v_tt;
		end;
		$func$;

		comment on function meteo_ddchm(timestamp) is 'Метео приближенный: ДДЧЧМ (день, часы, десятки минут)';
		comment on function meteo_vvvv(numeric) is 'Метео приближенный: ВВВВ (высота метеопоста)';
		comment on function meteo_bbbtt(numeric, numeric) is 'Метео приближенный: БББТТ (отклонение давления и температуры)';

	exception when others then
		raise notice 'ошибка в транзакции 3: %', sqlerrm;
		raise;
	end;

	commit;

end $$;