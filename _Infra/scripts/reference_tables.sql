do $$
begin

	begin
		-- стандарт высоты
		create table standard_heights(
			id integer not null,
			height integer not null
		);
		
		create sequence seq_standard_heights;
		alter table standard_heights alter column id set default nextval('seq_standard_heights');

		-- среднее отклонение C воздуха по стандарт высотам
		create table temperature_deviations(
			id integer not null,
			standard_height_id integer not null,
			surface_deviation integer not null,
			deviation integer not null
		);
		create sequence seq_temperature_deviations;
		alter table temperature_deviations alter column id set default nextval('seq_temperature_deviations');

		-- прибавки скорости ветра по стандарт высотам
		create table wind_speed_increments(
			id integer not null,
			eq_type_id integer not null,
			standard_height_id integer not null,
			argument_value integer not null,
			increment integer not null
		);
		create sequence seq_wind_speed_increments;
		alter table wind_speed_increments alter column id set default nextval('seq_wind_speed_increments');

		-- прибавки дирекц угла ветра по стандарт высотам
		create table wind_direction_increments(
			id integer not null,
			eq_type_id integer not null,
			standard_height_id integer not null,
			increment integer not null
		);

		
		create sequence seq_wind_direction_increments;
		alter table wind_direction_increments alter column id set default nextval('seq_wind_direction_increments');

		comment on table standard_heights is 'Справочник стандартных высот';
		comment on column standard_heights.id is 'Уникальный код';
		comment on column standard_heights.height is 'Высота, м';

		comment on table temperature_deviations is 'Среднее отклонение температуры воздуха по стандартным высотам (общий справочник для ДМК и ВР)';
		comment on column temperature_deviations.id is 'Уникальный код';
		comment on column temperature_deviations.standard_height_id is 'Код стандартной высоты';
		comment on column temperature_deviations.surface_deviation is 'Отклонение виртуальной температуры у земли, C (со знаком)';
		comment on column temperature_deviations.deviation is 'Среднее отклонение температуры на стандартной высоте, C (со знаком)';

		comment on table wind_speed_increments is 'Прибавки скорости ветра по стандартным высотам';
		comment on column wind_speed_increments.id is 'Уникальный код';
		comment on column wind_speed_increments.eq_type_id is 'Код типа оборудования';
		comment on column wind_speed_increments.standard_height_id is 'Код стандартной высоты';
		comment on column wind_speed_increments.argument_value is 'Значение аргумента: для ДМК скорость ветра у земли, м/с; для ВР дальность сноса ветровых пуль, м';
		comment on column wind_speed_increments.increment is 'Прибавка скорости ветра, м/с';


		comment on table wind_direction_increments is 'Прибавки дирекционного угла ветра по стандартным высотам';
		comment on column wind_direction_increments.id is 'Уникальный код';
		comment on column wind_direction_increments.eq_type_id is 'Код типа оборудования';
		comment on column wind_direction_increments.standard_height_id is 'Код стандартной высоты';
		comment on column wind_direction_increments.increment is 'Прибавка дирекционного угла, тысячные (1-00 хранится ккак 100)';

	exception when others then
		raise notice 'ошибка в транзакции 1: %', sqlerrm;
		raise;
	end;

	commit;


	begin
		alter table standard_heights add constraint pk_standard_heights primary key (id);
		alter table standard_heights add constraint uq_standard_heights_height unique (height);

		alter table temperature_deviations add constraint pk_temperature_deviations primary key (id);
		alter table temperature_deviations add constraint uq_temperature_deviations unique (standard_height_id, surface_deviation);
		alter table temperature_deviations add constraint fk_temperature_deviations_standard_height
			foreign key (standard_height_id) references standard_heights (id);

		alter table wind_speed_increments add constraint pk_wind_speed_increments primary key (id);
		alter table wind_speed_increments add constraint uq_wind_speed_increments unique (eq_type_id, standard_height_id, argument_value);
		alter table wind_speed_increments add constraint fk_wind_speed_increments_eq_type
			foreign key (eq_type_id) references eq_types (id);
		alter table wind_speed_increments add constraint fk_wind_speed_increments_standard_height
			foreign key (standard_height_id) references standard_heights (id);

		alter table wind_direction_increments add constraint pk_wind_direction_increments primary key (id);
		alter table wind_direction_increments add constraint uq_wind_direction_increments unique (eq_type_id, standard_height_id);
		alter table wind_direction_increments add constraint fk_wind_direction_increments_eq_type
			foreign key (eq_type_id) references eq_types (id);
		alter table wind_direction_increments add constraint fk_wind_direction_increments_standard_height
			foreign key (standard_height_id) references standard_heights (id);

	exception when others then
		raise notice 'ошибка в транзакции 2: %', sqlerrm;
		raise;
	end;

	commit;

end $$;