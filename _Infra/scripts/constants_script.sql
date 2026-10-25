do $$
begin
	begin
		create table meteo_constants(
			id integer not null,
			code varchar(100) not null,
			value numeric not null,
			description varchar(255) not null
		);
		create sequence seq_meteo_constants;
		alter table meteo_constants alter column id set default nextval('seq_meteo_constants');

		create table parameter_limits(
			id integer not null,
			parameter_type_id integer not null,
			eq_type_id integer not null,
			min_value numeric,
			max_value numeric,
			decimal_places integer
		);
		create sequence seq_parameter_limits;
		alter table parameter_limits alter column id set default nextval('seq_parameter_limits');

		comment on table meteo_constants is 'Константы расчета метео';
		comment on column meteo_constants.id is 'Уникальный код';
		comment on column meteo_constants.code is 'Код константы';
		comment on column meteo_constants.value is 'Значение';
		comment on column meteo_constants.description is 'Описание';

		comment on table parameter_limits is 'Допустимые значения входных параметров по типу оборудования';
		comment on column parameter_limits.id is 'Уникальный код';
		comment on column parameter_limits.parameter_type_id is 'Уникальный код типа параметра';
		comment on column parameter_limits.eq_type_id is 'Уникальный код типа оборудования';
		comment on column parameter_limits.min_value is 'Минимальное значение';
		comment on column parameter_limits.max_value is 'Максимальное значение';
		comment on column parameter_limits.decimal_places is 'Допустимое число знаков после запятой';

	exception when others then
		raise notice 'ошибка в транзакции 1: %', sqlerrm;
		raise;
	end;

	commit;


	begin
		insert into meteo_constants (code, value, description) values
			('table_pressure', 750, 'Табличное значение наземного давления, мм рт. ст.'),
			('table_temperature', 15.9, 'Табличное значение приземной виртуальной температуры, градусы Цельсия'),
			('negative_pressure_base', 500, 'Число, к которому прибавляется модуль отрицательного отклонения давления'),
			('negative_temperature_base', 50, 'Число, к которому прибавляется модуль отрицательного отклонения температуры');

		insert into parameter_limits (parameter_type_id, eq_type_id, min_value, max_value, decimal_places) values
			(1, 1, null, null, 0),
			(1, 2, null, null, 0),
			(2, 1, -58, 58, 1),
			(2, 2, -58, 58, 1),
			(3, 1, 500, 900, 0),
			(3, 2, 500, 900, 0),
			(4, 1, 0, 59, 0),
			(4, 2, 0, 59, 0),
			(5, 1, 0, 15, 0),
			(6, 2, 0, 150, 0);

	exception when others then
		raise notice 'ошибка в транзакции 2: %', sqlerrm;
		raise;
	end;

	commit;

	begin
		alter table meteo_constants add constraint pk_meteo_constants primary key (id);
		alter table meteo_constants add constraint uq_meteo_constants_code unique (code);

		alter table parameter_limits add constraint pk_parameter_limits primary key (id);
		alter table parameter_limits add constraint uq_parameter_limits_parameter_eq unique (parameter_type_id, eq_type_id);
		alter table parameter_limits add constraint fk_parameter_limits_parameter_types
			foreign key (parameter_type_id) references parameter_types (id);
		alter table parameter_limits add constraint fk_parameter_limits_eq_types
			foreign key (eq_type_id) references eq_types (id);

	exception when others then
		raise notice 'ошибка в транзакции 3: %', sqlerrm;
		raise;
	end;

	commit;

	begin
		create or replace function get_meteo_constant(p_code text)  -- функция получения знач конст по коду
		returns numeric
		language plpgsql
		as $func$
		declare
			result numeric;
		begin
			select value
			into result
			from meteo_constants
			where code = p_code;

			if result is null then
				raise exception 'константа % не найдена', p_code;
			end if;

			return result;
		end;
		$func$;

		comment on function get_meteo_constant(text) is 'Получение значения константы расчета метео по коду';

	exception when others then
		raise notice 'ошибка в транзакции 4: %', sqlerrm;
		raise;
	end;

	commit;

end $$;