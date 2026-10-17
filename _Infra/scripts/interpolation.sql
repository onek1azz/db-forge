do $$
begin

	begin
		create type interpolation_points as (
			x0 numeric,
			y0 numeric,
			x1 numeric,
			y1 numeric
		);

		create table calc_temperature_correction (
			temperature numeric(8,2) not null primary key,
			correction numeric(8,2) not null
		);

		insert into calc_temperature_correction (temperature, correction) values
			(0, 0), (5, 0.5), (10, 1), (15, 1), (20, 1.5), (25, 2), (30, 3.5), (40, 4.5);

		comment on type interpolation_points is 'Точки для линейной интерполяции';
		comment on column interpolation_points.x0 is 'Левая опорная точка';
		comment on column interpolation_points.y0 is 'Значение в левой опорной точке';
		comment on column interpolation_points.x1 is 'Правая опорная точка';
		comment on column interpolation_points.y1 is 'Значение в правой опорной точке';

		comment on table calc_temperature_correction is 'Опорные точки виртуальной поправки температуры';
		comment on column calc_temperature_correction.temperature is 'Температура';
		comment on column calc_temperature_correction.correction is 'Виртуальная поправка';

	exception when others then
		raise notice 'ошибка в транзакции 1 (тип и таблица): %', sqlerrm;
		raise;
	end;

	commit;


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
			from calc_temperature_correction;

			select lo.temperature, lo.correction, hi.temperature, hi.correction
			into result.x0, result.y0, result.x1, result.y1
			from (
				select temperature, correction
				from calc_temperature_correction
				where temperature <= v_temperature
				order by temperature desc
				limit 1
			) lo
			cross join (
				select temperature, correction
				from calc_temperature_correction
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

		create or replace function interpolate(p_x numeric, p_points interpolation_points)
		returns numeric
		language plpgsql
		as $func$
		begin
			if p_points.x1 = p_points.x0 then
				return p_points.y0;
			end if;

			return p_points.y0
				+ (p_x - p_points.x0) * (p_points.y1 - p_points.y0) / (p_points.x1 - p_points.x0);
		end;
		$func$;

		comment on function get_interpolation_points(numeric) is 'Определение точек интерполяции по температуре';
		comment on function interpolate(numeric, interpolation_points) is 'Линейная интерполяция значения x по заданным точкам';

	exception when others then
		raise notice 'ошибка в транзакции 2 (функции): %', sqlerrm;
		raise;
	end;

	commit;

end $$;