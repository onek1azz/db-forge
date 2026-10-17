do $$
declare
	rec record;
	points interpolation_points;
	result numeric;
begin
	for rec in
		select *
		from (values
			(cast(23 as numeric), cast(1.8 as numeric)),
			(3, 0.3),
			(25, 2),
			(0, 0),
			(10, 1),
			(40, 4.5),
			(-10, 0),
			(50, 4.5)
		) as t(temperature, expected)
	loop
		points := get_interpolation_points(rec.temperature);
		result := interpolate(rec.temperature, points);

		raise notice 't0 = %: точки (%, %) - (%, %), результат = %, ожидается % - %',
			rec.temperature, points.x0, points.y0, points.x1, points.y1,
			round(result, 2), rec.expected,
			case when round(result, 2) = rec.expected then 'ок' else 'ОШИБКА' end;
	end loop;
end $$;