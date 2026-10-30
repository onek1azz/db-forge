do $$
begin

	begin
		-- ограничения check из прошлого задания не дают сохр ошибочные значения, поэтому проверка параметров через check_parameters
		alter table parametrs drop constraint chk_temperature_range;
		alter table parametrs drop constraint chk_pressure_range;
		alter table parametrs drop constraint chk_wind_direction_range;
		alter table parametrs drop constraint chk_wind_speed_range;

	exception when others then
		raise notice 'ошибка в транзакции 1: %', sqlerrm;
		raise;
	end;

	commit;


	begin
		insert into users (full_name, position_id) values
			('Сидоров Сергей', 3), ('Козлов Константин', 1);

		-- пачки 3-10 (пачки 1 и 2 уже есть)
		insert into packs (user_id, eq_type_id, created_on) values
			(1, 1, date '2026-10-01'),
			(1, 1, date '2026-10-02'),
			(2, 2, date '2026-10-03'),
			(2, 2, date '2026-10-04'),
			(3, 1, date '2026-10-05'),
			(3, 2, date '2026-10-06'),
			(4, 1, date '2026-10-07'),
			(4, 2, date '2026-10-08');

		-- 1 высота, 2 температура, 3 давление, 4 направление ветра, 5 скорость ветра, 6 дальность сноса пуль
		insert into parametrs (pack_id, parameter_type_id, value) values
			-- пачка 3: без ошибок
			(3, 1, 100), (3, 2, 15), (3, 3, 750), (3, 4, 0), (3, 5, 5),
			-- пачка 4: температура вне диапазона
			(4, 1, 100), (4, 2, 70), (4, 3, 750), (4, 4, 10), (4, 5, 3),
			-- пачка 5: без ошибок
			(5, 1, 100), (5, 2, 12), (5, 3, 760), (5, 4, 20), (5, 6, 45),
			-- пачка 6: направление ветра вне диапазона, нет дальности сноса пуль
			(6, 1, 100), (6, 2, 10), (6, 3, 755), (6, 4, 65),
			-- пачка 7: скорость ветра вне диапазона, лишний знак у температуры
			(7, 1, 120), (7, 2, 23.45), (7, 3, 748), (7, 4, 30), (7, 5, 20),
			-- пачка 8: без ошибок
			(8, 1, 120), (8, 2, -5), (8, 3, 740), (8, 4, 30), (8, 6, 60),
			-- пачка 9: пустая, ну параметров нет
			-- пачка 10: без ошибок
			(10, 1, 90), (10, 2, 18), (10, 3, 752), (10, 4, 15), (10, 6, 30);

	exception when others then
		raise notice 'ошибка в транзакции 2: %', sqlerrm;
		raise;
	end;

	commit;

end $$;