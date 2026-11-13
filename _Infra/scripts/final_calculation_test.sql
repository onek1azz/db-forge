do $$
declare
	v_case record;
	v_row meteo_average_row;
	v_result meteo_average_row[];
	v_parameters parameter_list;
	v_bbbtt text;
	v_first boolean;
	v_actual text;
begin

	for v_case in
		select *
		from (values
			(1, 'пример 1: температура 23, ДМК', 1, 100, cast(23 as numeric), 760, 20, 6, cast(null as numeric), '01009', '09 21 09'),
			(2, 'пример 2: температура 25, ДМК', 1, 100, cast(25 as numeric), 765, 15, 6, cast(null as numeric), '01511', '11 16 09'),
			(3, 'пример из алгоритма ДМК: температура 3', 1, 100, cast(3 as numeric), 750, 10, 5, cast(null as numeric), '00063', '62 11 08'),
			(4, 'Ветровое ружье: дальность сноса 60', 2, 100, cast(15 as numeric), 750, 0, null, cast(60 as numeric), '00000', '00 00 05')
		) as t(
			num, title, eq_type_id, height, temperature, pressure, wind_direction,
			wind_speed, drift_range, expected_bbbtt, expected_200
		)
		order by num
	loop
		v_parameters := cast(row(
			v_case.eq_type_id, v_case.height, v_case.temperature, v_case.pressure,
			v_case.wind_direction, v_case.wind_speed, v_case.drift_range
		) as parameter_list);

		raise notice '';
		raise notice '=== % ===', v_case.title;
		raise notice 'Входные данные: высота %, температура %, давление %, направление %, скорость %, дальность сноса %',
			v_case.height, v_case.temperature, v_case.pressure, v_case.wind_direction,
			coalesce(cast(v_case.wind_speed as text), '-'), coalesce(cast(v_case.drift_range as text), '-');

		v_bbbtt := meteo_bbbtt(v_case.pressure, v_case.temperature);
		raise notice 'Заголовок: ДДЧЧМ %, ВВВВ %, БББТТ % (ожидается %) - %',
			meteo_ddchm(cast(now() as timestamp)), meteo_vvvv(v_case.height), v_bbbtt, v_case.expected_bbbtt,
			case when v_bbbtt = v_case.expected_bbbtt then 'ок' else 'ОШИБКА' end;

		call calc_meteo_average(v_parameters, v_case.eq_type_id, v_result);

		raise notice 'высота | ТТ | НН | СС';
		v_first := true;
		foreach v_row in array v_result loop
			raise notice '% | % | % | %',
				lpad(meteo_height(v_row.height), 6),
				meteo_tt(v_row.temperature_deviation),
				meteo_nn(v_row.wind_direction),
				meteo_cc(v_row.wind_speed);

			if v_first then
				v_actual := meteo_tt(v_row.temperature_deviation) || ' '
					|| meteo_nn(v_row.wind_direction) || ' '
					|| meteo_cc(v_row.wind_speed);
				raise notice 'Проверка для первой высоты: получено %, ожидается % - %',
					v_actual, v_case.expected_200,
					case when v_actual = v_case.expected_200 then 'ок' else 'ОШИБКА' end;
				v_first := false;
			end if;
		end loop;
	end loop;

end $$;