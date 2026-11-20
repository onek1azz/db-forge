do $$
declare
	-- границы периода, покрывают все данные бд front 2020-2023
	period_start constant date := cast('2020-01-01' as date);
	period_end constant date := cast('2023-12-01' as date);
begin

	begin

		create sequence seq_dim_time;
		create table dim_time
		(
			id bigint not null primary key default nextval('public.seq_dim_time'),
			month_start date not null,
			month_end date not null,
			month_name text not null,
			year integer not null,
			quarter_number integer not null,
			quarter_name text not null
		);


		comment on table dim_time is 'Время: месяцы и кварталы';
		comment on column dim_time.id is 'Уникальный код';
		comment on column dim_time.month_start is 'Дата начала месяца';
		comment on column dim_time.month_end is 'Дата окончания месяца';
		comment on column dim_time.month_name is 'Название месяца';
		comment on column dim_time.year is 'Год';
		comment on column dim_time.quarter_number is 'Номер квартала';
		comment on column dim_time.quarter_name is 'Название квартала';

		alter table dim_time add constraint uq_dim_time_month_start unique (month_start);


	exception when others then
		raise notice 'ошибка при создании таблицы времени: %', sqlerrm;
		raise;
	end;


	begin

		insert into dim_time (month_start, month_end, month_name, year, quarter_number, quarter_name)
		select
			cast(m as date),
			cast(m + interval '1 month' - interval '1 day' as date),
			(array['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
				'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'])[cast(extract(month from m) as integer)],
			cast(extract(year from m) as integer),
			cast(extract(quarter from m) as integer),
			cast(extract(quarter from m) as text) || ' квартал'
		from generate_series(period_start, period_end, interval '1 month') as m;

	exception when others then
		raise notice 'ошибка при заполнении таблицы времени: %', sqlerrm;
		raise;
	end;

	commit;
end $$;