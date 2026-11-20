do $$
begin

	-- ед измерения
	begin

		create sequence seq_dim_ranges;
		create table dim_ranges
		(
			id bigint not null primary key default nextval('public.seq_dim_ranges'),
			external_id bigint not null,
			name text not null,
			factor float,
			date_add timestamp not null default now()
		);

		comment on table dim_ranges is 'Единицы измерения';
		comment on column dim_ranges.id is 'Внутренний код';
		comment on column dim_ranges.external_id is 'Код в исходной базе';
		comment on column dim_ranges.name is 'Название';
		comment on column dim_ranges.factor is 'Коэффициент (размер порции)';
		comment on column dim_ranges.date_add is 'Дата добавления';



		alter table dim_ranges add constraint uq_dim_ranges_external_id unique (external_id);

	exception when others then
		raise notice 'ошибка при создании единиц измерения: %', sqlerrm;
		raise;
	end;


	-- категории товаров
	begin

		create sequence seq_dim_categories;
		create table dim_categories
		(
			id bigint not null primary key default nextval('public.seq_dim_categories'),
			external_id bigint not null,
			name text not null,
			parent_id bigint,
			date_add timestamp not null default now()
		);


		comment on table dim_categories is 'Категории товаров';
		comment on column dim_categories.id is 'Внутренний код';
		comment on column dim_categories.external_id is 'Код в исходной базе';
		comment on column dim_categories.name is 'Название';
		comment on column dim_categories.parent_id is 'Внутренний код родительской категории';
		comment on column dim_categories.date_add is 'Дата добавления';

		alter table dim_categories add constraint uq_dim_categories_external_id unique (external_id);
		alter table dim_categories add foreign key (parent_id) references dim_categories (id);


	exception when others then
		raise notice 'ошибка при создании категорий: %', sqlerrm;
		raise;
	end;

	-- товары
	begin

		create sequence seq_dim_products;
		create table dim_products
		
		(
			id bigint not null primary key default nextval('public.seq_dim_products'),
			external_id bigint not null,
			code text,
			name text not null,
			category_id bigint,
			range_id bigint,
			date_add timestamp not null default now()
		);

		comment on table dim_products is 'Товары';
		comment on column dim_products.id is 'Внутренний код';
		comment on column dim_products.external_id is 'Код в исходной базе';
		comment on column dim_products.code is 'Внешний код товара (по нему товар указан в журнале кассы)';
		comment on column dim_products.name is 'Название';
		comment on column dim_products.category_id is 'Внутренний код категории';
		comment on column dim_products.range_id is 'Внутренний код единицы измерения';
		comment on column dim_products.date_add is 'Дата добавления';

		alter table dim_products add constraint uq_dim_products_external_id unique (external_id);
		alter table dim_products add foreign key (category_id) references dim_categories (id);
		alter table dim_products add foreign key (range_id) references dim_ranges (id);

	exception when others then
		raise notice 'ошибка при создании товаров: %', sqlerrm;
		raise;
	end;

	-- поставщики
	begin

		create sequence seq_dim_vendors;
		create table dim_vendors
		(
			id bigint not null primary key default nextval('public.seq_dim_vendors'),
			external_id bigint not null,
			name text not null,
			group_external_id bigint,
			group_name text,
			date_add timestamp not null default now()
		);

		comment on table dim_vendors is 'Поставщики';
		comment on column dim_vendors.id is 'Внутренний код';
		comment on column dim_vendors.external_id is 'Код в исходной базе';
		comment on column dim_vendors.name is 'Название';
		comment on column dim_vendors.group_external_id is 'Код группы поставщиков в исходной базе';
		comment on column dim_vendors.group_name is 'Название группы поставщиков';
		comment on column dim_vendors.date_add is 'Дата добавления';

		alter table dim_vendors add constraint uq_dim_vendors_external_id unique (external_id);

	exception when others then
		raise notice 'ошибка при создании поставщиков: %', sqlerrm;
		raise;
	end;

	-- виды оплаты
	begin

		create sequence seq_dim_payment_types;
		create table dim_payment_types
		(
			id bigint not null primary key default nextval('public.seq_dim_payment_types'),
			external_id bigint not null,
			name text not null,
			date_add timestamp not null default now()
		);

		comment on table dim_payment_types is 'Виды оплаты';
		comment on column dim_payment_types.id is 'Внутренний код';
		comment on column dim_payment_types.external_id is 'Код в исходной базе';
		comment on column dim_payment_types.name is 'Название';
		comment on column dim_payment_types.date_add is 'Дата добавления';


		alter table dim_payment_types add constraint uq_dim_payment_types_external_id unique (external_id);

	exception when others then
		raise notice 'ошибка при создании видов оплаты: %', sqlerrm;
		raise;
	end;


	-- сотрудники
	begin

		create sequence seq_dim_employees;
		create table dim_employees
		(
			id bigint not null primary key default nextval('public.seq_dim_employees'),
			external_id bigint not null,
			name text not null,
			date_add timestamp not null default now()
		);


		comment on table dim_employees is 'Сотрудники';
		comment on column dim_employees.id is 'Внутренний код';
		comment on column dim_employees.external_id is 'Код в исходной базе';
		comment on column dim_employees.name is 'Имя сотрудника';
		comment on column dim_employees.date_add is 'Дата добавления';

		alter table dim_employees add constraint uq_dim_employees_external_id unique (external_id);

	exception when others then
		raise notice 'ошибка при создании сотрудников: %', sqlerrm;
		raise;
	end;


	-- склады
	begin

		create sequence seq_dim_storages;
		create table dim_storages
		
		(
			id bigint not null primary key default nextval('public.seq_dim_storages'),
			external_id bigint not null,
			name text not null,
			date_add timestamp not null default now()
		);

		comment on table dim_storages is 'Склады';
		comment on column dim_storages.id is 'Внутренний код';
		comment on column dim_storages.external_id is 'Код в исходной базе';
		comment on column dim_storages.name is 'Название';
		comment on column dim_storages.date_add is 'Дата добавления';

		alter table dim_storages add constraint uq_dim_storages_external_id unique (external_id);



	exception when others then
		raise notice 'ошибка при создании складов: %', sqlerrm;
		raise;
	end;

	-- причины списания
	begin

		create sequence seq_dim_reasons;
		create table dim_reasons
		(
			id bigint not null primary key default nextval('public.seq_dim_reasons'),
			external_id bigint not null,
			name text not null,
			parent_id bigint,
			date_add timestamp not null default now()
		);

		comment on table dim_reasons is 'Причины списания';
		comment on column dim_reasons.id is 'Внутренний код';
		comment on column dim_reasons.external_id is 'Код в исходной базе';
		comment on column dim_reasons.name is 'Название';
		comment on column dim_reasons.parent_id is 'Внутренний код родительской причины';
		comment on column dim_reasons.date_add is 'Дата добавления';

		
		alter table dim_reasons add constraint uq_dim_reasons_external_id unique (external_id);
		alter table dim_reasons add foreign key (parent_id) references dim_reasons (id);

	exception when others then
		raise notice 'ошибка при создании причин списания: %', sqlerrm;
		raise;
	end;


	commit;
end $$;