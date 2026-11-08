do $$
begin

	begin
		
		-- таблица стандарт высот
		create sequence calc_correction_height_seq;
		create table calc_correction_heights
		(
		        id integer primary key not null default nextval('public.calc_correction_height_seq'),
		        height integer not null
		);
		
		insert into calc_correction_heights(height)
		values(200),(400),(800),(1200),(1600),(2000),(2400),(3000),(4000);
	
		comment on table calc_correction_heights is 'Таблица стандартных высот';
		comment on column calc_correction_heights.id is 'Уникальный код';
		comment on column calc_correction_heights.height is 'Высота';
	
		-- справочник типов таблиц корректир
		create sequence calc_correction_types_seq;
		create table calc_correction_types
		(
		        id integer not null primary key default nextval('public.calc_correction_types_seq'),
		        parent_id integer,
		        measurment_equipment_id integer,
		        description text not null,
		        header_values integer[]
		);
	
		comment on table calc_correction_types is 'Справочник типов таблиц с собственными заголовками';
		comment on column calc_correction_types.id is 'Уникальный код';
		comment on column calc_correction_types.parent_id is 'Уникальный код владельца - тип таблицы';
		comment on column calc_correction_types.measurment_equipment_id is 'Тип оборудования';
		comment on column calc_correction_types.description is 'Описание к таблице';
		comment on column calc_correction_types.header_values is 'Значения в заголовке таблице';


		-- универсал таблица корректир
		create sequence calc_correction_seq;
		create table calc_correction
		(
		        id integer not null primary key default nextval('public.calc_correction_seq'),
		        height_id integer not null,
		        type_id integer not null,
		        row_values integer[]
		);

		comment on table calc_correction is 'Универсальная таблица корректировок';
		comment on column calc_correction.id is 'Уникальный код';
		comment on column calc_correction.height_id is 'Код высоты';
		comment on column calc_correction.type_id is 'Код типа таблиц';
		comment on column calc_correction.row_values is 'Значения с корректировками';
		

	end;	

	begin

		
		insert into calc_correction_types(  description, header_values)
		values( 'Таблица 2', array[0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 10, 20, 30, 40, 50]),   --  1
		( 'Таблица 3, скорость среднего ветра', null), -- 2
		( 'Таблица 3, направление среднего ветра', null);     -- 3

		insert into calc_correction_types( description, parent_id, measurment_equipment_id, header_values)
		values
		('Таблица 3, Скорость среднего ветра (ВР)', 2, 2, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]), -- 4
		('Таблица 3, Направление среднего ветра (ВР)',3, 2, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]),  --  5
		('Таблица 3, Скорость среднего ветра (ДМК)',2, 1, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]), -- 6
		('Таблица 3, Направление среднего ветра (ДМК)',3, 1, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);  -- 7

		
		insert into calc_correction_types( description, parent_id)
		values('Таблица 2, Положительные температуры', 1 ),   -- 8
		('Таблица 2, Отрицательные температуры', 1 )  -- 9
		;

		
		insert into calc_correction(height_id, type_id, row_values )
		
		-- табл 2, отриц знач
		values(1, 8, array[-1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -20, -29, -39, -49]), -- 200
		(2, 8, array[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -39, -48]),  --  400
		(3, 8, array[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]),  --  800
		(4, 8, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]),  --  1200
		-- табл 2, полож знач
		(1, 7, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),  -- 200
		(2, 7, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),  -- 400
		(3, 7, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),  -- 800
		(4, 7, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),  -- 1200
		-- табл 3, скорость сред ветра (вр)
		(1, 4, array[3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 12]),  --  200
		(2, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15]),   -- 400
		(3, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15 ,16]), -- 800
		(4, 4, array[4, 5, 7, 8, 8, 9, 11, 12, 13, 15 ,15, 16]),  -- 1200
		-- табл 3, направление сред ветра (вр)
		(1, 5, array[0]), -- 200
		(2, 5, array[1]), -- 400
		(3, 5, array[2]), -- 800
		(4, 5, array[2]), -- 1200
		-- табл 3, скорость сред ветра (дмк)
		(1, 6, array[4,6,8,9,10,12,14,15,16,18,20,21,22]), -- 200
		(2, 6, array[5,7,10,11,12,14,17,18,20,22,23,25,27]),  -- 400
		(3, 6, array[5,8,10,11,13,15,18,19,21,23,25,27,28]), --  800
		(4, 6, array[5,8,11,12,13,16,19,20,23,24,26,28,30]), -- 1200
		-- 'табл 3, направление сред ветра (дмк)
		(1, 7, array[1]), --  200
		(2, 7, array[2]),  -- 400
		(3, 7, array[3]),  -- 800
		(4, 7, array[3]) --  1200
		;
		
	end;

	begin
		alter table public.calc_temperature_correction rename to calc_correction_temperature;
		
		CREATE OR REPLACE FUNCTION public.fn_calc_temperature_interpolation(
			par_temperature numeric)
		    RETURNS numeric
		    LANGUAGE 'plpgsql'
		    COST 100
		    VOLATILE PARALLEL UNSAFE
		AS $BODY$
				        declare 
				                var_interpolation interpolation_points;
				                var_result numeric(8,2) default 0;
				                var_min_temparure numeric(8,2) default 0;
				                var_max_temperature numeric(8,2) default 0;
				                var_denominator numeric(8,2) default 0;
				        begin
				
				                                raise notice 'Расчет интерполяции для температуры %', par_temperature;
				
				                if exists (select 1 from public.calc_correction_temperature where temperature = par_temperature ) then
				                begin
				                        select correction 
				                        into  var_result 
				                        from  public.calc_correction_temperature
				                        where 
				                                temperature = par_temperature;
				                end;
				                else    
				                begin
				                        select min(temperature), max(temperature) 
				                        into var_min_temparure, var_max_temperature
				                        from public.calc_correction_temperature;
				
				                        if par_temperature < var_min_temparure or   
				                           par_temperature > var_max_temperature then
				
				                                raise exception 'Некорректно передан параметр! Невозможно рассчитать поправку. Значение должно укладываться в диаппазон: %, %',
				                                        var_min_temparure, var_max_temperature;
				                        end if;   
				
				
				                        select x0, y0, x1, y1 
				                                                 into var_interpolation.x0, var_interpolation.y0, var_interpolation.x1, var_interpolation.y1
				                        from
				                        (
				                                select t1.temperature as x0, t1.correction as y0
				                                from public.calc_correction_temperature as t1
				                                where t1.temperature <= par_temperature
				                                order by t1.temperature desc
				                                limit 1
				                        ) as leftPart
				                        cross join
				                        (
				                                select t1.temperature as x1, t1.correction as y1
				                                from public.calc_correction_temperature as t1
				                                where t1.temperature >= par_temperature
				                                order by t1.temperature 
				                                limit 1
				                        ) as rightPart;
				
				                        raise notice 'Граничные значения %', var_interpolation;
				                        var_result :=  interpolate( par_temperature,  var_interpolation);
				                                                 
				                end;
				                end if;
				
				                                return var_result;
				
				end;
				
		$BODY$;
		
		
		COMMENT ON FUNCTION public.fn_calc_temperature_interpolation(numeric)
		    IS 'Функция для расчета интерполяции для метео приближенный';
	end;

	commit;

	-- адаптировал под мою базу
	begin
		create or replace function get_interpolation_points(p_temperature numeric)
		returns interpolation_points
		language plpgsql
		as $func$
		declare
			result interpolation_points;
			v_temperature numeric;
		begin
			select greatest(min(temperature), least(max(temperature), p_temperature))
			into v_temperature
			from calc_correction_temperature;

			select lo.temperature, lo.correction, hi.temperature, hi.correction
			into result.x0, result.y0, result.x1, result.y1
			from (
				select temperature, correction
				from calc_correction_temperature
				where temperature <= v_temperature
				order by temperature desc
				limit 1
			) lo
			cross join (
				select temperature, correction
				from calc_correction_temperature
				where temperature >= v_temperature
				order by temperature asc
				limit 1
			) hi;

			if result.x0 is null or result.x1 is null then
				raise exception 'не найдены точки интерполяции для температуры %', p_temperature;
			end if;

			return result;
		end;
		$func$;

	exception when others then
		raise notice 'ошибка в транзакции 4 (функция подбора точек): %', sqlerrm;
		raise;
	end;

	commit;


	-- и исправление данных скрипта
	begin

		update calc_correction set type_id = 9 where type_id = 8;
		update calc_correction set type_id = 8 where type_id = 7 and cardinality(row_values) > 1;

		update calc_correction set row_values[13] = -38 where height_id = 2 and type_id = 9;
		update calc_correction set row_values[9] = 22 where height_id = 4 and type_id = 6;

		update calc_correction_types
		set header_values = array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]
		where id = 1;


		update calc_correction_types t
		set header_values = p.header_values
		from calc_correction_types p
		where p.id = t.parent_id and t.id in (8, 9);

	exception when others then
		raise notice 'ошибка в транзакции 5 (исправление данных): %', sqlerrm;
		raise;
	end;

	commit;


	-- добавил данные которых не хватало
	begin
		insert into calc_correction(height_id, type_id, row_values)
		values
			-- табл 2, отриц знач
			(5, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]), --  1600
			(6, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]), --  2000
			(7, 9, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]), --  2400
			(8, 9, array[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]), --  3000
			(9, 9, array[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]), --  4000
			-- табл 2, полож знач
			(5, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),  --  1600
			(6, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),  --  2000
			(7, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),  --  2400
			(8, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),  --  3000
			(9, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),  --  4000
			-- табл 3, скорость сред ветра (вр)  
			(5, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17]), -- 1600
			(6, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 16, 17, 18]), -- 2000
			(7, 4, array[4, 6, 8, 9, 9, 10, 12, 14, 15, 16, 18, 19]), -- 2400
			(8, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 18, 19]), --  3000
			(9, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 16, 18, 19, 20]),  -- 4000
			-- табл 3, направление сред ветра (вр)
			(5, 5, array[3]), -- 1600
			(6, 5, array[3]), -- 2000
			(7, 5, array[3]), -- 2400
			(8, 5, array[4]), -- 3000
			(9, 5, array[4]), -- 4000
			-- табл 3, скорость сред ветра (дмк)  
			(5, 6, array[6, 8, 11, 13, 14, 17, 20, 21, 23, 25, 27, 29, 32]), -- 1600
			(6, 6, array[6, 9, 11, 13, 14, 17, 20, 21, 24, 26, 28, 30, 32]), -- 2000
			(7, 6, array[6, 9, 12, 14, 15, 18, 21, 22, 25, 27, 29, 32, 34]), -- 2400
			(8, 6, array[6, 9, 12, 14, 15, 18, 21, 23, 25, 28, 30, 32, 36]), -- 3000
			(9, 6, array[6, 10, 12, 14, 16, 19, 22, 24, 26, 29, 32, 34, 36]), -- 4000
			-- табл 3, направление сред ветра (дмк) 
			(5, 7, array[4]),   -- 1600
			(6, 7, array[4]),   -- 2000
			(7, 7, array[4]),   -- 2400
			(8, 7, array[5]),   -- 3000
			(9, 7, array[5]);   -- 4000

	exception when others then
		raise notice 'ошибка в транзакции 6 (добавление данных): %', sqlerrm;
		raise;
	end;

	commit;


	begin
		create sequence calc_correction_header_seq;
		create table calc_correction_headers
		(
			id integer not null default nextval('public.calc_correction_header_seq'),
			description text not null,
			header_values integer[] not null
		);

		comment on table calc_correction_headers is 'Справочник заголовков таблиц корректировок';
		comment on column calc_correction_headers.id is 'Уникальный код';
		comment on column calc_correction_headers.description is 'Описание заголовка';
		comment on column calc_correction_headers.header_values is 'Значения в заголовке таблицы';

		insert into calc_correction_headers(description, header_values)
		values
			('Таблица 2: отклонение приземной виртуальной температуры, град',
				array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
			('Таблица 3 (ВР): дальность сноса ветровых пуль, м',
				array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]),
			('Таблица 3 (ДМК): скорость ветра у земли, м/с',
				array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

		alter table calc_correction_types add column code varchar(50);
		alter table calc_correction_types add column header_id integer;
		alter table calc_correction_types add column parameter_type_id integer;
		alter table calc_correction_types rename column measurment_equipment_id to eq_type_id;

		update calc_correction_types t
		set code = v.code
		from (values
			(1, 'temperature'),
			(2, 'wind_speed'),
			(3, 'wind_direction'),
			(4, 'wind_speed_vr'),
			(5, 'wind_direction_vr'),
			(6, 'wind_speed_dmk'),
			(7, 'wind_direction_dmk'),
			(8, 'temperature_positive'),
			(9, 'temperature_negative')
		) as v(id, code)
		where t.id = v.id;

		alter table calc_correction_types alter column code set not null;

		-- заголовок хранится там в отдельной таблице, и у типов остаается только ссылка на него (но у типов группп и у направления ветра заголовок по факту не нужен)
		update calc_correction_types t
		set header_id = h.id
		from calc_correction_headers h
		where t.header_values = h.header_values
			and t.code in ('temperature_positive', 'temperature_negative', 'wind_speed_vr', 'wind_speed_dmk');

		alter table calc_correction_types drop column header_values;

		-- вход табл 3, у ДМК скорость ветра, у ВР дальность сноса пуль
		update calc_correction_types t
		set parameter_type_id = pt.id
		from parameter_types pt
		where (t.code = 'wind_speed_dmk' and pt.code = 'wind_speed')
			or (t.code = 'wind_speed_vr' and pt.code = 'drift_range');

		comment on table calc_correction_types is 'Справочник типов таблиц корректировок';
		comment on column calc_correction_types.code is 'Код типа таблицы';
		comment on column calc_correction_types.header_id is 'Код заголовка таблицы';
		comment on column calc_correction_types.eq_type_id is 'Тип оборудования';
		comment on column calc_correction_types.parameter_type_id is 'Параметр, значение которого является входом таблицы';

	exception when others then
		raise notice 'ошибка в транзакции 7 (заголовки): %', sqlerrm;
		raise;
	end;

	commit;



	begin
		alter table calc_correction_headers add constraint pk_calc_correction_headers primary key (id);

		alter table calc_correction_heights add constraint uq_calc_correction_heights_height unique (height);

		alter table calc_correction_types add constraint uq_calc_correction_types_code unique (code);
		alter table calc_correction_types add constraint fk_calc_correction_types_parent
			foreign key (parent_id) references calc_correction_types (id);
		alter table calc_correction_types add constraint fk_calc_correction_types_eq_type
			foreign key (eq_type_id) references eq_types (id);
		alter table calc_correction_types add constraint fk_calc_correction_types_header
			foreign key (header_id) references calc_correction_headers (id);
		alter table calc_correction_types add constraint fk_calc_correction_types_parameter_type
			foreign key (parameter_type_id) references parameter_types (id);

		alter table calc_correction alter column row_values set not null;
		alter table calc_correction add constraint uq_calc_correction unique (height_id, type_id);
		alter table calc_correction add constraint fk_calc_correction_height
			foreign key (height_id) references calc_correction_heights (id);
		alter table calc_correction add constraint fk_calc_correction_type
			foreign key (type_id) references calc_correction_types (id);


	exception when others then
		raise notice 'ошибка в транзакции 8 (ключи и связи): %', sqlerrm;
		raise;
	end;

	commit;




	begin
		-- константы расчета
		insert into meteo_constants (code, value, description)
		values
			('temperature_max_column', 50, 'Последний столбец таблицы 2, отклонения больше раскладываются на него и остаток'),
			('direction_divisions', 60, 'Число больших делений угломера в окружности');

		-- строка результата расчета по высоте
		create type meteo_average_row as (
			height integer,
			temperature_deviation integer,
			wind_direction integer,
			wind_speed integer
		);

		comment on type meteo_average_row is 'Результат расчета по стандартной высоте';
		comment on column meteo_average_row.height is 'Стандартная высота, м';
		comment on column meteo_average_row.temperature_deviation is 'Среднее отклонение температуры, град (со знаком)';
		comment on column meteo_average_row.wind_direction is 'Направление среднего ветра, большие деления угломера';
		comment on column meteo_average_row.wind_speed is 'Скорость среднего ветра, м/с';

		create or replace function get_correction_value(p_height_id integer, p_type_id integer, p_argument numeric)
		returns numeric
		language plpgsql
		as $func$
		declare
			v_header integer[];
			v_row integer[];
			v_lower integer;
			v_upper integer;
		begin
			select h.header_values
			into v_header
			from calc_correction_types t
			inner join calc_correction_headers h on h.id = t.header_id
			where t.id = p_type_id;

			select c.row_values
			into v_row
			from calc_correction c
			where c.height_id = p_height_id and c.type_id = p_type_id;

			if v_header is null or v_row is null then
				return null;
			end if;

			select max(u.ord) into v_lower
			from unnest(v_header) with ordinality as u(val, ord)
			where u.val <= p_argument;

			select min(u.ord) into v_upper
			from unnest(v_header) with ordinality as u(val, ord)
			where u.val >= p_argument;

			--  вход за краем таблицы приводится к ближ столбцу
			
			if v_lower is null then
				v_lower := v_upper;
			end if;
			if v_upper is null then
				v_upper := v_lower;
			end if;

			-- в таблице нет такого знач
			
			if v_lower > cardinality(v_row) or v_upper > cardinality(v_row) then
				return null;
			end if;

			if v_lower = v_upper then
				return v_row[v_lower];
			end if;

			return interpolate(
				p_argument,
				cast(row(v_header[v_lower], v_row[v_lower], v_header[v_upper], v_row[v_upper]) as interpolation_points)
			);
		end;
		$func$;

   
		create or replace function calc_temperature_average_deviation(p_height_id integer, p_deviation integer)
		returns integer
		language plpgsql
		as $func$
		declare
			v_type_id integer;
			v_tens integer := (abs(p_deviation) / 10) * 10;
			v_units integer := abs(p_deviation) % 10;
			v_columns integer[] := array[]::integer[];
			v_column integer;
			v_value numeric;
			v_sum numeric := 0;
			v_max_column integer := cast(get_meteo_constant('temperature_max_column') as integer);
		begin
			if p_deviation = 0 then
				return 0;
			end if;

			select t.id
			into v_type_id
			from calc_correction_types t
			where t.code = case when p_deviation < 0 then 'temperature_negative' else 'temperature_positive' end;

			--  десятки больше последнего столбца раскладываются на него и остаток
			if v_tens > v_max_column then
				v_columns := array[v_max_column, v_tens - v_max_column];
			elsif v_tens > 0 then
				v_columns := array[v_tens];
			end if;

			if v_units > 0 then
				v_columns := v_columns || v_units;
			end if;

			foreach v_column in array v_columns loop
				v_value := get_correction_value(p_height_id, v_type_id, v_column);

				 --  у положит отклонений 40 и 50 в таблице значений нет, сред отклонение = самому отклонению как у остальных столбцов
				if v_value is null then
					v_value := sign(p_deviation) * v_column;
				end if;

				v_sum := v_sum + v_value;
			end loop;

			return cast(v_sum as integer);
		end;
		$func$;

		-- расчет по каждой стандарт высоте, результат возвр в параметре p_result
		create or replace procedure calc_meteo_average(
			p_parameters parameter_list,
			p_eq_type_id integer,
			inout p_result meteo_average_row[]
		)
		language plpgsql
		as $proc$
		declare
			v_errors text;
			v_deviation integer;
			v_argument numeric;
			v_speed_type_id integer;
			v_direction_type_id integer;
			v_threshold integer;
			v_divisions integer := cast(get_meteo_constant('direction_divisions') as integer);
			v_height record;
			v_row meteo_average_row;
			v_speed numeric;
			v_increment integer;
		begin
			p_result := array[]::meteo_average_row[];

			v_errors := check_parameters(cast(row(
				p_eq_type_id, p_parameters.height, p_parameters.temperature, p_parameters.pressure,
				p_parameters.wind_direction, p_parameters.wind_speed, p_parameters.drift_range
			) as parameter_list));

			if v_errors <> '' then
				raise exception 'Некорректные входные параметры: %', v_errors;
			end if;

			-- отклонение приземной виртуальной темпы от табличного знач
			v_deviation := cast(round(
				p_parameters.temperature
				+ interpolate(p_parameters.temperature, get_interpolation_points(p_parameters.temperature))
				- get_meteo_constant('table_temperature')
			) as integer);

			-- табл скорости ветра для типа оборуд и ее вход, параметр берется из справочника типов, знач из входных параметров
			select t.id, cast(to_jsonb(p_parameters) ->> pt.code as numeric)
			into v_speed_type_id, v_argument
			from calc_correction_types t
			inner join calc_correction_types p on p.id = t.parent_id
			inner join parameter_types pt on pt.id = t.parameter_type_id
			where p.code = 'wind_speed' and t.eq_type_id = p_eq_type_id;

			select t.id
			into v_direction_type_id
			from calc_correction_types t
			inner join calc_correction_types p on p.id = t.parent_id
			where p.code = 'wind_direction' and t.eq_type_id = p_eq_type_id;

			-- меньше 1го столбца таблицы 3 скорость сред ветра = 0
			select h.header_values[1]
			into v_threshold
			from calc_correction_types t
			inner join calc_correction_headers h on h.id = t.header_id
			where t.id = v_speed_type_id;

			for v_height in
				select h.id, h.height
				from calc_correction_heights h
				order by h.height
			loop
				v_row.height := v_height.height;
				v_row.temperature_deviation := calc_temperature_average_deviation(v_height.id, v_deviation);

				if v_argument < v_threshold then
					v_row.wind_direction := 0;
					v_row.wind_speed := 0;
				else
					v_speed := get_correction_value(v_height.id, v_speed_type_id, v_argument);

					select c.row_values[1]
					into v_increment
					from calc_correction c
					where c.height_id = v_height.id and c.type_id = v_direction_type_id;

					v_row.wind_speed := cast(round(v_speed) as integer);
					v_row.wind_direction := mod(cast(p_parameters.wind_direction as integer) + v_increment, v_divisions);
				end if;

				p_result := p_result || v_row;
			end loop;
		end;
		$proc$;


		create or replace function meteo_height(p_height integer)
		returns text
		language plpgsql
		as $func$
		begin
			return lpad(cast(p_height / 100 as text), 2, '0');
		end;
		$func$;

		create or replace function meteo_tt(p_deviation integer)
		returns text
		language plpgsql
		as $func$
		begin
			if p_deviation < 0 then
				return cast(cast(get_meteo_constant('negative_temperature_base') as integer) + abs(p_deviation) as text);
			end if;

			return lpad(cast(p_deviation as text), 2, '0');
		end;
		$func$;

		create or replace function meteo_nn(p_direction integer)
		returns text
		language plpgsql
		as $func$
		begin
			return lpad(cast(p_direction as text), 2, '0');
		end;
		$func$;

		create or replace function meteo_cc(p_speed integer)
		returns text
		language plpgsql
		as $func$
		begin
			return lpad(cast(p_speed as text), 2, '0');
		end;
		$func$;


		comment on function get_correction_value(integer, integer, numeric) is 'Значение из таблицы корректировок по высоте, типу таблицы и входу';
		comment on function calc_temperature_average_deviation(integer, integer) is 'Среднее отклонение температуры на высоте по таблице 2';
		comment on procedure calc_meteo_average(parameter_list, integer, meteo_average_row[]) is 'Расчет метео приближенный по каждой стандартной высоте';
		comment on function meteo_height(integer) is 'Метео приближенный: строка высоты (сотни метров)';
		comment on function meteo_tt(integer) is 'Метео приближенный: ТТ (отклонение температуры)';
		comment on function meteo_nn(integer) is 'Метео приближенный: НН (направление среднего ветра)';
		comment on function meteo_cc(integer) is 'Метео приближенный: СС (скорость среднего ветра)';

	exception when others then
		raise notice 'ошибка в транзакции 9 (расчет): %', sqlerrm;
		raise;
	end;

	commit;

end $$;