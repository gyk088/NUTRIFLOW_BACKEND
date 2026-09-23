--
-- PostgreSQL database dump
--

\restrict LiDzoYecFrVHul3RdHmc4iYFzWJuouosAm1AG1cSL5NFkma8daBgtSaNcOO0l2S

-- Dumped from database version 18.2 (Debian 18.2-1.pgdg13+1)
-- Dumped by pg_dump version 18.2 (Debian 18.2-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dictionary_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dictionary_update (
    name character varying(40) NOT NULL,
    utime timestamp(6) with time zone DEFAULT now()
);


--
-- Name: TABLE dictionary_update; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.dictionary_update IS 'Время последнего изменения справочника — обновляется сервисным слоем при любом create/update/delete в этом справочнике';


--
-- Name: COLUMN dictionary_update.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dictionary_update.name IS 'Имя справочника: ingredient | recipe | tag';


--
-- Name: COLUMN dictionary_update.utime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dictionary_update.utime IS 'Время последнего изменения справочника';


--
-- Name: ingredient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ingredient (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name_ru character varying(100) CONSTRAINT ingredient_name_not_null NOT NULL,
    image_url character varying(500),
    grams_per_unit jsonb DEFAULT '{}'::jsonb,
    calories numeric(10,3) DEFAULT 0 NOT NULL,
    protein numeric(10,3) DEFAULT 0 NOT NULL,
    carbs numeric(10,3) DEFAULT 0 NOT NULL,
    fat numeric(10,3) DEFAULT 0 NOT NULL,
    fiber numeric(10,3) DEFAULT 0 NOT NULL,
    sugar numeric(10,3) DEFAULT 0 NOT NULL,
    saturated_fat numeric(10,3) DEFAULT 0 NOT NULL,
    cholesterol numeric(10,3) DEFAULT 0 NOT NULL,
    sodium numeric(10,3) DEFAULT 0 NOT NULL,
    omega_3 numeric(10,3) DEFAULT 0 NOT NULL,
    omega_6 numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_a numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_b1 numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_b2 numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_b3 numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_b5 numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_b6 numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_b7 numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_b9 numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_b12 numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_c numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_d numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_e numeric(10,3) DEFAULT 0 NOT NULL,
    vitamin_k numeric(10,3) DEFAULT 0 NOT NULL,
    calcium numeric(10,3) DEFAULT 0 NOT NULL,
    iron numeric(10,3) DEFAULT 0 NOT NULL,
    magnesium numeric(10,3) DEFAULT 0 NOT NULL,
    phosphorus numeric(10,3) DEFAULT 0 NOT NULL,
    potassium numeric(10,3) DEFAULT 0 NOT NULL,
    zinc numeric(10,3) DEFAULT 0 NOT NULL,
    copper numeric(10,3) DEFAULT 0 NOT NULL,
    manganese numeric(10,3) DEFAULT 0 NOT NULL,
    selenium numeric(10,3) DEFAULT 0 NOT NULL,
    iodine numeric(10,3) DEFAULT 0 NOT NULL,
    ctime timestamp(6) with time zone DEFAULT now(),
    utime timestamp(6) with time zone,
    name_en character varying(100) NOT NULL
);


--
-- Name: TABLE ingredient; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ingredient IS 'Ингредиент (продукт) — базовая сущность приложения. Все нутриенты указаны на 100 г / 100 мл продукта';


--
-- Name: COLUMN ingredient.name_ru; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingredient.name_ru IS 'Название на русском';


--
-- Name: COLUMN ingredient.grams_per_unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingredient.grams_per_unit IS 'jsonb: вес в граммах для штучных/объёмных единиц измерения, напр. {"piece": 150, "tbsp": 13.5}';


--
-- Name: COLUMN ingredient.calories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingredient.calories IS 'ккал на 100 г/мл';


--
-- Name: COLUMN ingredient.ctime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingredient.ctime IS 'Дата создания';


--
-- Name: COLUMN ingredient.utime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingredient.utime IS 'Дата обновления';


--
-- Name: COLUMN ingredient.name_en; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingredient.name_en IS 'Название на английском';


--
-- Name: ingredient_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ingredient_tag (
    ingredient_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


--
-- Name: TABLE ingredient_tag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ingredient_tag IS 'Связь ингредиента с тегами (аллергены и т.п., по аналогии с recipe_tag)';


--
-- Name: my_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.my_item (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    name character varying(200) NOT NULL,
    ctime timestamp(6) with time zone DEFAULT now(),
    utime timestamp(6) with time zone
);


--
-- Name: my_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.my_session (
    user_id uuid NOT NULL,
    token character varying(256) NOT NULL,
    fcm_token character varying(256),
    user_agent character varying(256),
    ip character varying(32),
    impersonated_by uuid,
    ctime timestamp(6) with time zone DEFAULT now(),
    utime timestamp(6) with time zone
);


--
-- Name: TABLE my_session; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.my_session IS 'Таблица сессий';


--
-- Name: COLUMN my_session.token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_session.token IS 'токен для авторизации';


--
-- Name: COLUMN my_session.ctime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_session.ctime IS 'Дата создания';


--
-- Name: COLUMN my_session.utime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_session.utime IS 'Дата обновления';


--
-- Name: my_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.my_user (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(40),
    surname character varying(40),
    email character varying(100),
    password character varying(64),
    role character varying(40),
    ctime timestamp(6) with time zone DEFAULT now(),
    utime timestamp(6) with time zone,
    active boolean DEFAULT true,
    reset_token character varying(64),
    reset_token_expires timestamp(6) with time zone,
    sex character varying(10),
    age smallint,
    height_cm numeric(5,1),
    weight_kg numeric(5,1),
    target_weight_kg numeric(5,1),
    activity_level character varying(20),
    goal_type character varying(20),
    manual_calorie_target integer,
    manual_macro_split jsonb,
    preferences jsonb DEFAULT '{}'::jsonb
);


--
-- Name: TABLE my_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.my_user IS 'Таблица пользователей';


--
-- Name: COLUMN my_user.ctime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_user.ctime IS 'Дата создания';


--
-- Name: COLUMN my_user.utime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_user.utime IS 'Дата редактирования';


--
-- Name: COLUMN my_user.sex; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_user.sex IS 'male | female';


--
-- Name: COLUMN my_user.activity_level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_user.activity_level IS 'sedentary | light | moderate | active | very-active';


--
-- Name: COLUMN my_user.goal_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_user.goal_type IS 'lose-weight | maintain-weight | gain-weight | build-muscle | eat-healthier';


--
-- Name: COLUMN my_user.manual_calorie_target; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_user.manual_calorie_target IS 'Ручной таргет по калориям, если задан — переопределяет расчёт по TDEE';


--
-- Name: COLUMN my_user.manual_macro_split; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_user.manual_macro_split IS 'Ручной сплит БЖУ {protein, carbs, fat} (доли от 0 до 1), если задан';


--
-- Name: COLUMN my_user.preferences; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.my_user.preferences IS 'jsonb: {dietaryTags[], allergies[], dislikedIngredientIds[], favoriteCuisines[], units}';


--
-- Name: recipe; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipe (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name_ru character varying(150) CONSTRAINT recipe_name_not_null NOT NULL,
    description_ru text,
    image_url character varying(500),
    servings smallint DEFAULT 1 NOT NULL,
    ctime timestamp(6) with time zone DEFAULT now(),
    utime timestamp(6) with time zone,
    cook_time_ru character varying(100),
    steps_ru text,
    name_en character varying(150) NOT NULL,
    description_en text,
    steps_en text,
    cook_time_en character varying(100)
);


--
-- Name: TABLE recipe; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.recipe IS 'Рецепт блюда';


--
-- Name: COLUMN recipe.name_ru; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.name_ru IS 'Название на русском';


--
-- Name: COLUMN recipe.description_ru; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.description_ru IS 'Описание на русском';


--
-- Name: COLUMN recipe.servings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.servings IS 'На сколько порций рассчитан рецепт';


--
-- Name: COLUMN recipe.ctime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.ctime IS 'Дата создания';


--
-- Name: COLUMN recipe.utime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.utime IS 'Дата обновления';


--
-- Name: COLUMN recipe.cook_time_ru; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.cook_time_ru IS 'Время готовки на русском (свободный текст)';


--
-- Name: COLUMN recipe.steps_ru; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.steps_ru IS 'Шаги приготовления на русском';


--
-- Name: COLUMN recipe.name_en; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.name_en IS 'Название на английском';


--
-- Name: COLUMN recipe.description_en; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.description_en IS 'Описание на английском';


--
-- Name: COLUMN recipe.steps_en; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.steps_en IS 'Шаги приготовления на английском';


--
-- Name: COLUMN recipe.cook_time_en; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe.cook_time_en IS 'Время готовки на английском (свободный текст)';


--
-- Name: recipe_ingredient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipe_ingredient (
    recipe_id uuid NOT NULL,
    ingredient_id uuid NOT NULL,
    quantity numeric(10,3) NOT NULL,
    unit character varying(20) DEFAULT 'g'::character varying NOT NULL
);


--
-- Name: TABLE recipe_ingredient; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.recipe_ingredient IS 'Состав рецепта: какие ингредиенты и в каком количестве входят в одну порцию блюда';


--
-- Name: COLUMN recipe_ingredient.quantity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe_ingredient.quantity IS 'Количество ингредиента на одну порцию в единицах, указанных в unit';


--
-- Name: COLUMN recipe_ingredient.unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.recipe_ingredient.unit IS 'Единица измерения: g, kg, ml, l, piece, tbsp, tsp, cup, slice, clove и т.д. Для не-весовых единиц перевод в граммы — через ingredient.grams_per_unit';


--
-- Name: recipe_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipe_tag (
    recipe_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


--
-- Name: TABLE recipe_tag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.recipe_tag IS 'Связь рецепта с тегами (категория, тип приёма пищи, диетические пометки, аллергены...)';


--
-- Name: tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type character varying(30) NOT NULL,
    name_ru character varying(60) CONSTRAINT tag_name_not_null NOT NULL,
    name_en character varying(60) NOT NULL,
    ctime timestamp(6) with time zone DEFAULT now(),
    utime timestamp(6) with time zone
);


--
-- Name: TABLE tag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tag IS 'Тег для рецепта. type задаёт группу тега (category, meal_type, dietary, allergen и т.д.), name — значение (breakfast, vegetarian, gluten...)';


--
-- Name: COLUMN tag.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tag.type IS 'Тип тега, напр. category, meal_type, dietary, allergen';


--
-- Name: COLUMN tag.name_ru; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tag.name_ru IS 'Название на русском';


--
-- Name: COLUMN tag.name_en; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tag.name_en IS 'Название на английском';


--
-- Name: COLUMN tag.ctime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tag.ctime IS 'Дата создания';


--
-- Name: COLUMN tag.utime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tag.utime IS 'Дата обновления';


--
-- Data for Name: dictionary_update; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dictionary_update (name, utime) FROM stdin;
\.


--
-- Data for Name: ingredient; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ingredient (id, name_ru, image_url, grams_per_unit, calories, protein, carbs, fat, fiber, sugar, saturated_fat, cholesterol, sodium, omega_3, omega_6, vitamin_a, vitamin_b1, vitamin_b2, vitamin_b3, vitamin_b5, vitamin_b6, vitamin_b7, vitamin_b9, vitamin_b12, vitamin_c, vitamin_d, vitamin_e, vitamin_k, calcium, iron, magnesium, phosphorus, potassium, zinc, copper, manganese, selenium, iodine, ctime, utime, name_en) FROM stdin;
b75a7fb9-17cd-4bd3-8463-368f0312e201	Сливочное масло	\N	{"tbsp": 14}	717.000	0.900	0.100	81.000	0.000	0.000	51.000	215.000	11.000	0.000	0.000	684.000	0.000	0.030	0.000	0.000	0.000	0.000	0.000	0.000	0.000	1.500	2.300	7.000	24.000	0.000	0.000	24.000	24.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.754+00	\N	Butter
bbbcfad0-2ac8-46ac-bb5e-3a12a9ae8c1a	sdfsdfsdf	http://localhost:3000/files/30167ec7-e1dd-4264-a1ae-85f04badae07.png	{}	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-17 08:12:54.353+00	\N	sdfsdfsdf
1d8538a5-2082-4d35-99bf-843ed8c18e3c	Яйцо	\N	{"piece": 50}	143.000	12.600	0.700	9.500	0.000	0.000	3.100	372.000	142.000	0.000	0.000	160.000	0.070	0.500	0.100	1.400	0.100	0.000	47.000	1.100	0.000	2.000	1.000	0.300	56.000	1.800	10.000	198.000	138.000	1.300	0.010	0.030	30.000	24.000	2026-09-20 20:06:50.519+00	\N	Egg
dbf4a44b-1ac1-4286-9504-16c426b5e7f5	Куриная грудка	\N	{}	165.000	31.000	0.000	3.600	0.000	0.000	1.000	85.000	74.000	0.000	0.000	0.000	0.070	0.100	13.700	1.000	0.600	0.000	4.000	0.300	0.000	0.000	0.300	0.300	15.000	1.000	29.000	220.000	256.000	1.000	0.000	0.000	27.000	0.000	2026-09-20 20:06:50.535+00	\N	Chicken breast
2af5b797-0881-4733-accb-506cf8ec9c78	Куриное бедро	\N	{}	209.000	26.000	0.000	10.900	0.000	0.000	3.000	95.000	90.000	0.000	0.000	0.000	0.080	0.190	5.300	1.100	0.300	0.000	6.000	0.300	0.000	0.000	0.300	0.000	12.000	1.300	23.000	180.000	240.000	2.000	0.000	0.000	18.000	0.000	2026-09-20 20:06:50.546+00	\N	Chicken thigh
c5be005b-8c20-45f7-8293-053ba6f5f95d	Говяжий фарш (85/15)	\N	{}	215.000	26.000	0.000	12.000	0.000	0.000	4.600	78.000	66.000	0.000	0.000	0.000	0.050	0.150	5.000	0.500	0.300	0.000	8.000	2.600	0.000	0.000	0.200	1.600	18.000	2.600	20.000	200.000	270.000	4.800	0.000	0.000	18.000	0.000	2026-09-20 20:06:50.558+00	\N	Ground beef (85/15)
d264ca43-6833-40ba-8cf5-97594ec7ed5e	Индюшиный фарш	\N	{}	149.000	24.000	0.000	5.000	0.000	0.000	1.400	88.000	79.000	0.000	0.000	0.000	0.060	0.180	6.500	0.900	0.500	0.000	7.000	1.600	0.000	0.000	0.200	0.000	20.000	1.600	22.000	190.000	230.000	2.100	0.000	0.000	25.000	0.000	2026-09-20 20:06:50.57+00	\N	Ground turkey
98050983-dc6a-4dc4-831d-5a3ed5541e5d	Индюшиная грудка	\N	{}	135.000	30.000	0.000	1.000	0.000	0.000	0.300	65.000	55.000	0.000	0.000	0.000	0.050	0.120	8.100	0.800	0.600	0.000	6.000	0.400	0.000	0.000	0.100	0.000	14.000	1.000	28.000	210.000	270.000	1.300	0.000	0.000	24.000	0.000	2026-09-20 20:06:50.581+00	\N	Turkey breast
ae064946-d37b-46c0-b521-21d1f09c37b7	Говяжья вырезка (сирлойн)	\N	{}	183.000	27.000	0.000	7.500	0.000	0.000	3.000	80.000	58.000	0.000	0.000	0.000	0.080	0.180	6.000	0.500	0.400	0.000	7.000	2.400	0.000	0.000	0.200	1.600	13.000	2.300	22.000	210.000	315.000	5.000	0.000	0.000	20.000	0.000	2026-09-20 20:06:50.592+00	\N	Beef sirloin
9f29da31-fc50-4255-9f46-3eea489efbe3	Бекон	\N	{"slice": 8}	541.000	37.000	1.400	42.000	0.000	0.000	14.000	110.000	1717.000	0.000	0.000	0.000	0.400	0.150	6.000	0.700	0.400	0.000	0.000	0.700	0.000	0.000	0.300	0.000	11.000	1.400	22.000	200.000	565.000	2.600	0.000	0.000	20.000	0.000	2026-09-20 20:06:50.603+00	\N	Bacon
a9c2aca7-7390-4af3-a5f4-c19c2f822fb1	Канадский бекон	\N	{"slice": 28}	145.000	21.000	1.400	6.000	0.000	0.000	2.000	50.000	1350.000	0.000	0.000	0.000	0.700	0.200	5.000	0.000	0.400	0.000	0.000	0.600	0.000	0.000	0.000	0.000	8.000	0.800	20.000	250.000	340.000	2.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.613+00	\N	Canadian bacon
c77109ba-d9d5-487e-be10-9134ca9ff4b6	Копчёный лосось	\N	{}	117.000	18.300	0.000	4.300	0.000	0.000	0.900	23.000	672.000	1.000	0.000	0.000	0.020	0.100	6.900	0.000	0.300	0.000	2.000	3.300	0.000	8.000	1.100	0.100	9.000	0.700	18.000	180.000	149.000	0.200	0.000	0.000	25.000	0.000	2026-09-20 20:06:50.624+00	\N	Smoked salmon
2b6db454-cfdd-4105-bbb7-75b71fa8eb27	Филе лосося	\N	{}	208.000	20.000	0.000	13.000	0.000	0.000	3.100	55.000	59.000	2.300	0.000	0.000	0.200	0.150	8.500	1.700	0.600	0.000	26.000	3.200	0.000	11.000	1.100	0.500	9.000	0.300	27.000	240.000	384.000	0.400	0.000	0.000	36.000	0.000	2026-09-20 20:06:50.637+00	\N	Salmon fillet
8a2618a7-1fb5-4fd4-9326-62336adc3508	Филе трески	\N	{}	82.000	18.000	0.000	0.700	0.000	0.000	0.100	43.000	54.000	0.150	0.000	0.000	0.080	0.060	2.100	0.200	0.200	0.000	7.000	0.900	0.000	0.000	0.600	0.100	16.000	0.400	32.000	203.000	413.000	0.500	0.030	0.000	33.000	0.000	2026-09-20 20:06:50.649+00	\N	Cod fillet
6665d4dd-2e53-4c42-a259-247ea6adcf35	Стейк тунца	\N	{}	144.000	23.300	0.000	4.900	0.000	0.000	1.300	38.000	39.000	1.200	0.000	0.000	0.240	0.090	9.900	0.800	0.900	0.000	2.000	2.200	0.000	3.000	1.000	0.100	8.000	1.000	35.000	254.000	252.000	0.600	0.000	0.000	80.000	0.000	2026-09-20 20:06:50.663+00	\N	Tuna steak
7049f9f9-6892-403c-9915-76c67abd77b6	Тунец консервированный (в собственном соку)	\N	{}	116.000	26.000	0.000	0.800	0.000	0.000	0.200	30.000	247.000	0.300	0.000	0.000	0.030	0.060	11.300	0.000	0.350	0.000	2.000	2.500	0.000	1.000	0.600	0.000	11.000	1.300	29.000	158.000	237.000	0.500	0.000	0.000	78.000	0.000	2026-09-20 20:06:50.675+00	\N	Canned tuna (in water)
d2ae29d7-17a4-40db-89e8-b20c8f698488	Креветки	\N	{}	99.000	24.000	0.200	0.300	0.000	0.000	0.100	189.000	111.000	0.000	0.000	0.000	0.030	0.030	2.600	0.000	0.100	0.000	3.000	1.100	0.000	0.000	1.300	0.000	70.000	0.500	39.000	237.000	259.000	1.300	0.300	0.000	40.000	35.000	2026-09-20 20:06:50.689+00	\N	Shrimp
8e80d460-222c-4969-83c7-7d3bd8ef2979	Греческий йогурт (натуральный)	\N	{}	97.000	9.000	3.900	5.000	0.000	3.900	3.200	13.000	36.000	0.000	0.000	27.000	0.020	0.300	0.100	0.300	0.060	0.000	0.000	0.750	0.000	0.000	0.000	0.000	110.000	0.050	11.000	135.000	141.000	0.500	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.703+00	\N	Greek yogurt (plain)
8ab706f2-1c77-478a-9e31-e1d04f27224c	Молоко (2%)	\N	{}	50.000	3.400	4.900	2.000	0.000	4.900	1.200	8.000	44.000	0.000	0.000	46.000	0.040	0.180	0.100	0.360	0.040	0.000	0.000	0.500	0.000	1.300	0.000	0.000	120.000	0.030	12.000	93.000	150.000	0.400	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.716+00	\N	Milk (2%)
80b87ca3-1251-4761-a315-e866c230c08b	Миндальное молоко (несладкое)	\N	{}	15.000	0.600	0.600	1.200	0.000	0.000	0.100	0.000	63.000	0.000	0.000	50.000	0.000	0.030	0.000	0.000	0.000	0.000	0.000	0.000	0.000	1.000	5.300	0.000	188.000	0.300	5.000	20.000	20.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.728+00	\N	Almond milk (unsweetened)
b53e5343-7e07-4574-8d72-43cdf0187014	Сливки жирные	\N	{}	340.000	2.100	2.800	36.000	0.000	2.900	23.000	110.000	27.000	0.000	0.000	350.000	0.000	0.150	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.500	0.000	0.700	65.000	0.000	7.000	54.000	75.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.74+00	\N	Heavy cream
e489a9b7-4df7-4d1c-b736-6fee915e9ae7	Сливочный сыр	\N	{"tbsp": 14.5}	342.000	6.000	4.100	34.000	0.000	0.000	19.000	101.000	321.000	0.000	0.000	308.000	0.000	0.150	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.300	0.000	0.000	98.000	0.200	6.000	98.000	138.000	0.500	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.766+00	\N	Cream cheese
f6576856-fb2a-4789-a7a8-0daef7f9949f	Сыр фета	\N	{}	264.000	14.000	4.000	21.000	0.000	0.000	15.000	89.000	917.000	0.000	0.000	145.000	0.000	0.800	0.000	0.000	0.400	0.000	0.000	1.700	0.000	0.000	0.000	0.000	493.000	0.700	19.000	337.000	62.000	2.900	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.778+00	\N	Feta cheese
e0c7a66e-0716-43c1-8027-b1e721108d5b	Сыр пармезан	\N	{}	431.000	38.000	4.100	29.000	0.000	0.000	19.000	88.000	1529.000	0.000	0.000	220.000	0.000	0.400	0.000	0.000	0.090	0.000	0.000	1.300	0.000	0.000	0.000	0.000	1184.000	0.800	44.000	694.000	92.000	2.900	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.79+00	\N	Parmesan cheese
645bcd1c-a04a-4498-9541-21a9ea7d3447	Сыр чеддер	\N	{}	403.000	25.000	1.300	33.000	0.000	0.000	21.000	105.000	653.000	0.000	0.000	265.000	0.000	0.400	0.000	0.000	0.070	0.000	0.000	0.800	0.000	0.000	0.000	2.400	721.000	0.700	28.000	512.000	98.000	3.100	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.804+00	\N	Cheddar cheese
82a7642e-d453-4360-ae0c-de1328d37580	Моцарелла свежая	\N	{}	280.000	22.000	2.200	21.000	0.000	0.000	13.000	79.000	373.000	0.000	0.000	179.000	0.000	0.300	0.000	0.000	0.000	0.000	0.000	1.200	0.000	0.000	0.000	0.000	505.000	0.400	20.000	354.000	76.000	2.900	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.816+00	\N	Fresh mozzarella
6d89dc43-e48b-4005-bbfe-363cb552d0f5	Сыр рикотта	\N	{}	174.000	11.300	3.000	13.000	0.000	0.000	8.000	51.000	84.000	0.000	0.000	120.000	0.000	0.200	0.000	0.000	0.000	0.000	0.000	0.340	0.000	0.000	0.000	0.000	207.000	0.400	11.000	158.000	105.000	1.200	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.827+00	\N	Ricotta cheese
bb7cae1c-9ed6-43cd-9b3f-3e5b8c148f88	Творог	\N	{}	98.000	11.000	3.400	4.300	0.000	2.700	2.700	17.000	364.000	0.000	0.000	37.000	0.000	0.200	0.000	0.000	0.000	0.000	0.000	0.400	0.000	0.000	0.000	0.000	83.000	0.100	8.000	159.000	104.000	0.400	0.000	0.000	12.000	0.000	2026-09-20 20:06:50.839+00	\N	Cottage cheese
6cf8dd84-bc6e-4e68-878c-6c115bb36862	Сметана	\N	{}	198.000	2.400	4.600	19.400	0.000	3.500	12.000	59.000	42.000	0.000	0.000	187.000	0.000	0.200	0.000	0.000	0.000	0.000	0.000	0.200	0.000	0.000	0.000	0.000	96.000	0.100	8.000	75.000	141.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.852+00	\N	Sour cream
64493b76-b118-4fae-b92e-be8f70bc2b4c	Хлеб на закваске	\N	{"slice": 30}	273.000	10.800	53.000	1.300	2.400	2.500	0.000	0.000	526.000	0.000	0.000	0.000	0.400	0.200	3.600	0.000	0.000	0.000	60.000	0.000	0.000	0.000	0.000	0.000	47.000	3.500	30.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.866+00	\N	Sourdough bread
aa53b8ba-121c-4cde-af29-a3a0be157270	Хлеб для сэндвичей	\N	{"slice": 30}	266.000	9.000	49.000	3.300	2.700	5.000	0.000	0.000	490.000	0.000	0.000	0.000	0.400	0.300	4.600	0.000	0.000	0.000	130.000	0.000	0.000	0.000	0.000	0.000	151.000	3.600	23.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.876+00	\N	Sandwich bread
8ca5c6e4-0495-45c9-b0d0-6f46a1b5f51f	Багет	\N	{"slice": 25}	274.000	9.000	55.000	1.700	2.400	3.500	0.000	0.000	550.000	0.000	0.000	0.000	0.400	0.250	3.900	0.000	0.000	0.000	100.000	0.000	0.000	0.000	0.000	0.000	60.000	3.000	22.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.89+00	\N	Baguette
e6887371-382e-4c0c-b841-1a40e6c9f897	Бейгл	\N	{"piece": 95}	257.000	10.000	50.000	1.500	2.100	5.500	0.000	0.000	460.000	0.000	0.000	0.000	0.400	0.250	3.900	0.000	0.000	0.000	110.000	0.000	0.000	0.000	0.000	0.000	60.000	2.900	23.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.903+00	\N	Bagel
ebce98c5-24da-49a1-97d3-553bf577ab4e	Английский маффин	\N	{"piece": 57}	227.000	8.200	44.000	1.600	2.600	2.500	0.000	0.000	393.000	0.000	0.000	0.000	0.300	0.200	3.000	0.000	0.000	0.000	90.000	0.000	0.000	0.000	0.000	0.000	150.000	2.200	17.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.916+00	\N	English muffin
310f681b-20dc-46f5-9fe0-8876bf5cdb37	Пшеничная тортилья	\N	{"piece": 45}	289.000	7.800	48.000	6.400	2.600	2.000	0.000	0.000	590.000	0.000	0.000	0.000	0.300	0.200	2.500	0.000	0.000	0.000	80.000	0.000	0.000	0.000	0.000	0.000	120.000	2.000	20.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.931+00	\N	Flour tortilla wrap
d5aeb1bd-2947-43b4-9db4-e61457dd759d	Кукурузная тортилья	\N	{"piece": 24}	218.000	5.700	44.600	2.900	6.400	0.900	0.000	0.000	12.000	0.000	0.000	0.000	0.050	0.040	0.900	0.000	0.000	0.000	6.000	0.000	0.000	0.000	0.000	0.000	81.000	0.600	35.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:50.943+00	\N	Corn tortilla
b4533f1f-9c8e-47fe-9341-1f3e9e370b83	Овсяные хлопья	\N	{"cup": 90}	379.000	13.200	67.700	6.500	10.100	1.000	0.000	0.000	0.000	0.000	0.000	0.000	0.760	0.000	0.000	1.300	0.100	0.000	32.000	0.000	0.000	0.000	0.700	0.000	52.000	4.700	177.000	410.000	429.000	4.000	0.000	4.900	0.000	0.000	2026-09-20 20:06:50.956+00	\N	Rolled oats
0dafbe10-2d43-4b04-ae62-43c02a6617ec	Рис белый (сырой)	\N	{"cup": 185}	365.000	7.100	80.000	0.700	1.300	0.100	0.000	0.000	0.000	0.000	0.000	0.000	0.070	0.050	1.600	0.000	0.160	0.000	8.000	0.000	0.000	0.000	0.000	0.000	28.000	0.800	25.000	115.000	115.000	1.100	0.000	1.100	0.000	0.000	2026-09-20 20:06:50.97+00	\N	White rice (uncooked)
53cc9824-7c3b-4016-8ba2-74dee527ccc8	Киноа (сырая)	\N	{"cup": 170}	368.000	14.100	64.000	6.100	7.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.360	0.320	1.500	0.000	0.500	0.000	184.000	0.000	0.000	0.000	2.400	0.000	47.000	4.600	197.000	457.000	563.000	3.100	0.600	2.600	0.000	0.000	2026-09-20 20:06:50.983+00	\N	Quinoa (uncooked)
50f81ce7-3738-474e-b2aa-7abc41f3e299	Паста (сырая)	\N	{}	371.000	13.000	74.700	1.500	3.200	2.700	0.000	0.000	0.000	0.000	0.000	0.000	0.150	0.070	2.000	0.000	0.000	0.000	18.000	0.000	0.000	0.000	0.000	0.000	21.000	3.300	53.000	0.000	223.000	1.500	0.000	1.300	60.000	0.000	2026-09-20 20:06:50.994+00	\N	Pasta (uncooked)
9a77127b-1ca1-415a-a7da-e55c282d1ed5	Яичная лапша (сырая)	\N	{}	384.000	14.000	71.000	4.500	3.200	1.800	0.000	95.000	0.000	0.000	0.000	0.000	0.300	0.200	3.400	0.000	0.000	0.000	100.000	0.000	0.000	0.000	0.000	0.000	19.000	1.900	33.000	0.000	172.000	1.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.011+00	\N	Egg noodles (uncooked)
57a086d7-a00f-4e41-84ac-e6a0cc2e5663	Панировочные сухари	\N	{"cup": 108}	395.000	13.000	72.000	5.300	4.900	6.200	0.000	0.000	732.000	0.000	0.000	0.000	0.400	0.300	4.900	0.000	0.000	0.000	130.000	0.000	0.000	0.000	0.000	0.000	83.000	4.100	33.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.025+00	\N	Breadcrumbs
a9a1bad9-4eca-43e7-b6d7-ee335e2702c8	Мука пшеничная	\N	{}	364.000	10.300	76.300	1.000	2.700	0.300	0.000	0.000	0.000	0.000	0.000	0.000	0.500	0.300	5.000	0.000	0.000	0.000	183.000	0.000	0.000	0.000	0.000	0.000	15.000	4.600	22.000	0.000	107.000	0.700	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.04+00	\N	All-purpose flour
be39aa1e-2b5d-4da0-bc4e-f05b09216616	Гранола	\N	{"cup": 100}	471.000	10.000	64.000	20.000	7.000	24.000	3.000	0.000	0.000	0.000	0.000	0.000	0.200	0.100	0.000	0.000	0.100	0.000	0.000	0.000	0.000	0.000	2.000	0.000	60.000	2.800	120.000	0.000	300.000	2.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.054+00	\N	Granola
9926a47f-28d3-46bc-90bd-b22c64193ab3	Гренки	\N	{}	407.000	10.000	66.000	11.000	4.900	4.400	0.000	0.000	900.000	0.000	0.000	0.000	0.300	0.200	4.000	0.000	0.000	0.000	100.000	0.000	0.000	0.000	0.000	0.000	70.000	3.000	20.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.07+00	\N	Croutons
6084fb0c-f8df-486d-8bbd-4166cdeaaf22	Нут консервированный	\N	{}	139.000	7.500	22.500	2.600	6.300	3.900	0.000	0.000	240.000	0.000	0.000	0.000	0.060	0.000	0.000	0.000	0.100	0.000	65.000	0.000	0.000	0.000	0.000	4.000	49.000	1.600	33.000	109.000	210.000	1.500	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.083+00	\N	Chickpeas (canned)
903b3ad7-3dfd-4549-bfc8-f891ab7f7a93	Красная чечевица (сырая)	\N	{}	352.000	24.600	63.400	1.100	10.700	2.000	0.000	0.000	0.000	0.000	0.000	0.000	0.870	0.210	2.600	0.000	0.500	0.000	479.000	0.000	0.000	0.000	0.500	0.000	56.000	6.500	122.000	454.000	955.000	4.800	0.900	1.400	0.000	0.000	2026-09-20 20:06:51.097+00	\N	Red lentils (uncooked)
75f64318-0e35-4497-922b-cef681139d83	Мёд	\N	{"tsp": 7, "tbsp": 21}	304.000	0.300	82.400	0.000	0.000	82.100	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.040	0.100	0.000	0.020	0.000	0.000	0.000	0.500	0.000	0.000	0.000	6.000	0.000	2.000	4.000	52.000	0.200	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.109+00	\N	Honey
0e4d9d9a-37e9-482b-89dd-2ab597222cc7	Арахисовая паста	\N	{"tbsp": 16}	588.000	25.000	20.000	50.000	6.000	9.000	10.000	0.000	0.000	0.000	0.000	0.000	0.100	0.100	13.500	0.000	0.500	0.000	87.000	0.000	0.000	0.000	9.400	0.000	43.000	1.900	168.000	0.000	649.000	2.900	0.400	1.700	0.000	0.000	2026-09-20 20:06:51.122+00	\N	Peanut butter
a4bcc641-2afb-4ef4-b6a1-6caa3a24c409	Тёмный шоколад (70%)	\N	{}	598.000	7.800	45.900	42.600	11.000	24.000	24.500	0.000	0.000	0.000	0.000	0.000	0.000	0.100	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.600	6.000	73.000	11.900	228.000	308.000	715.000	3.300	1.800	0.000	0.000	0.000	2026-09-20 20:06:51.135+00	\N	Dark chocolate (70%)
f43f4e55-e108-4ac9-a9a3-0b5127659e3c	Семена чиа	\N	{"tbsp": 12}	486.000	16.500	42.100	30.700	34.400	0.000	0.000	0.000	0.000	17.800	0.000	0.000	0.600	0.170	8.800	0.000	0.000	0.000	49.000	0.000	0.000	0.000	0.000	0.000	631.000	7.700	335.000	860.000	407.000	4.600	0.900	2.700	0.000	0.000	2026-09-20 20:06:51.146+00	\N	Chia seeds
457f1060-ef40-4a5b-a2df-85f2e1d7a435	Грецкие орехи	\N	{}	654.000	15.200	13.700	65.200	6.700	2.600	6.100	0.000	0.000	9.100	38.100	0.000	0.340	0.000	0.000	0.000	0.500	0.000	98.000	0.000	0.000	0.000	0.700	2.700	98.000	2.900	158.000	346.000	441.000	3.100	1.600	3.400	0.000	0.000	2026-09-20 20:06:51.16+00	\N	Walnuts
ae3e9146-ec42-4d2b-96da-07245ad8b468	Кедровые орехи	\N	{}	673.000	13.700	13.100	68.400	3.700	3.600	4.900	0.000	0.000	0.000	33.200	0.000	0.360	0.230	4.400	0.000	0.090	0.000	34.000	0.000	0.000	0.000	9.300	53.900	16.000	5.500	251.000	575.000	597.000	6.500	1.300	8.800	0.000	0.000	2026-09-20 20:06:51.174+00	\N	Pine nuts
3837182b-4acc-401b-beb5-0db0de087bc3	Кунжутные семена	\N	{}	573.000	17.700	23.400	49.700	11.800	0.300	7.000	0.000	0.000	0.000	0.000	0.000	0.790	0.250	4.500	0.000	0.790	0.000	97.000	0.000	0.000	0.000	0.250	0.000	975.000	14.600	351.000	629.000	468.000	7.800	4.100	2.500	0.000	0.000	2026-09-20 20:06:51.187+00	\N	Sesame seeds
9142f0e2-55d3-4ee9-8cf9-edfb498c9313	Разрыхлитель	\N	{"tsp": 4.6}	53.000	0.000	27.700	0.000	0.000	0.000	0.000	0.000	10600.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	5876.000	0.000	0.000	7069.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.199+00	\N	Baking powder
45ec108e-6d34-4295-a61f-c2aea959e8ac	Соевый соус	\N	{"tbsp": 18}	53.000	8.000	4.900	0.600	0.000	0.400	0.000	0.000	5493.000	0.000	0.000	0.000	0.000	0.000	1.600	0.000	0.200	0.000	32.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	52.000	170.000	379.000	0.000	0.000	0.600	0.000	0.000	2026-09-20 20:06:51.21+00	\N	Soy sauce
8465a410-b52c-4577-bbd9-d4080183de05	Бальзамический уксус	\N	{"tbsp": 16}	88.000	0.500	17.000	0.000	0.000	15.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	27.000	0.700	0.000	0.000	112.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.218+00	\N	Balsamic vinegar
da0566f8-8a43-4429-b0db-a3a94942a9d3	Оливковое масло	\N	{"tsp": 4.5, "tbsp": 13.5}	884.000	0.000	0.000	100.000	0.000	0.000	13.800	0.000	0.000	0.000	9.800	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	14.400	60.200	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.227+00	\N	Olive oil
44d967f0-d877-42b4-ab3c-10c46941b746	Кунжутное масло	\N	{"tsp": 4.5}	884.000	0.000	0.000	100.000	0.000	0.000	14.200	0.000	0.000	0.300	41.300	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	1.400	13.600	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.236+00	\N	Sesame oil
f3244cab-948a-43e9-9d33-514996ddee16	Майонез	\N	{"tbsp": 13}	680.000	1.000	0.600	75.000	0.000	0.000	11.800	42.000	635.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	16.000	0.000	0.000	0.000	0.000	0.000	20.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.256+00	\N	Mayonnaise
583d36ed-70c5-42d4-a2b3-87bc4e4b8a8e	Соус «Цезарь»	\N	{"tbsp": 15}	467.000	2.200	6.000	49.000	0.000	0.000	7.500	30.000	1050.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	8.000	0.000	20.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.274+00	\N	Caesar dressing
f45f8e71-2fc6-41b0-aeec-559aec2a74a8	Порошок карри	\N	{"tsp": 2, "tbsp": 6}	325.000	12.700	55.800	14.000	33.200	2.800	0.000	0.000	0.000	0.000	0.000	1350.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	11.000	0.000	21.000	1.000	478.000	29.600	281.000	0.000	1543.000	4.300	1.300	7.600	0.000	0.000	2026-09-20 20:06:51.298+00	\N	Curry powder
b6c6ed4e-8ab6-4c1c-86a0-d1ca720dcaae	Зира (кумин)	\N	{"tsp": 2}	375.000	17.800	44.200	22.300	10.500	2.300	0.000	0.000	0.000	0.000	0.000	1270.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	7.700	0.000	3.300	5.400	931.000	66.400	366.000	499.000	1788.000	4.800	0.900	0.000	0.000	0.000	2026-09-20 20:06:51.312+00	\N	Cumin
bad18d5c-4b6d-451f-8182-0ae50d044c1d	Корица	\N	{"tsp": 2.6}	247.000	4.000	80.600	1.200	53.100	2.200	0.000	0.000	0.000	0.000	0.000	15.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	3.800	0.000	0.000	31.000	1002.000	8.300	0.000	0.000	431.000	1.800	0.340	17.500	0.000	0.000	2026-09-20 20:06:51.328+00	\N	Cinnamon
0c0cee98-5262-43c9-b3bb-590c8a0df4e3	Мускатный орех	\N	{"tsp": 2.2}	525.000	5.800	49.300	36.300	20.800	2.900	0.000	0.000	0.000	0.000	0.000	102.000	0.350	0.000	0.000	0.000	0.160	0.000	0.000	0.000	3.000	0.000	0.000	0.000	184.000	3.000	183.000	0.000	350.000	2.200	1.020	2.900	0.000	0.000	2026-09-20 20:06:51.338+00	\N	Nutmeg
f885e5af-eee5-44b5-9f91-58ed0b8fec09	Хлопья чили	\N	{"tsp": 1.8}	282.000	12.000	50.000	14.300	27.200	10.000	0.000	0.000	0.000	0.000	0.000	41610.000	0.000	0.000	0.000	0.000	2.450	0.000	0.000	0.000	76.400	0.000	29.800	80.000	148.000	7.800	152.000	0.000	2014.000	2.500	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.346+00	\N	Chili flakes
f4782639-7872-4b98-8db0-49fa4aac8d04	Порошок матча	\N	{"tsp": 2}	324.000	30.000	39.000	5.000	38.000	0.000	0.000	0.000	0.000	0.000	0.000	2200.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	8.000	0.000	20.000	700.000	420.000	35.000	230.000	190.000	2500.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.357+00	\N	Matcha powder
5f556406-9f30-40a1-bdd9-214ebc44ddca	Кокосовое молоко (консервированное)	\N	{}	230.000	2.300	5.500	24.000	0.000	3.300	21.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2.800	0.000	0.200	0.000	18.000	1.600	37.000	100.000	263.000	0.700	0.300	0.900	0.000	0.000	2026-09-20 20:06:51.366+00	\N	Coconut milk (canned)
7906ec51-1bcd-43ae-9e0c-d0f9c01f73c1	Овощной бульон	\N	{}	5.000	0.300	0.900	0.100	0.000	0.000	0.000	0.000	340.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	9.000	0.000	0.000	0.000	180.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.374+00	\N	Vegetable broth
90523ff2-a007-4c89-b75d-47645a6285ea	Куриный бульон	\N	{}	8.000	1.200	0.500	0.300	0.000	0.000	0.000	0.000	343.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	56.000	130.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.383+00	\N	Chicken broth
0b7b1ddb-9929-4352-9924-0ca61a7a3b59	Томаты консервированные	\N	{}	24.000	1.100	5.300	0.200	1.400	3.200	0.000	0.000	186.000	0.000	0.000	42.000	0.000	0.000	0.000	0.000	0.000	0.000	9.000	0.000	13.000	0.000	0.500	4.000	24.000	1.200	15.000	0.000	218.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.391+00	\N	Canned tomatoes
c4bef9db-8cbd-4b30-b5aa-acdd7f9ac8c3	Томатный соус	\N	{}	29.000	1.300	6.600	0.200	1.600	4.100	0.000	0.000	383.000	0.000	0.000	38.000	0.000	0.000	0.000	0.000	0.000	0.000	12.000	0.000	9.000	0.000	0.700	5.000	20.000	1.000	20.000	0.000	297.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.401+00	\N	Tomato sauce
b6f720c8-2e7b-4f8e-adb4-b57022d99a0f	Авокадо	\N	{"piece": 150}	160.000	2.000	8.500	14.700	6.700	0.700	2.100	0.000	0.000	0.000	0.000	0.000	0.070	0.130	1.700	1.400	0.300	0.000	81.000	0.000	10.000	0.000	2.100	21.000	12.000	0.600	29.000	52.000	485.000	0.600	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.409+00	\N	Avocado
8f897f2e-ef63-4dbd-9baf-284dddde8a96	Лимон	\N	{"piece": 58}	29.000	1.100	9.300	0.300	2.800	2.500	0.000	0.000	0.000	0.000	0.000	0.000	0.040	0.000	0.000	0.000	0.080	0.000	11.000	0.000	53.000	0.000	0.150	0.000	26.000	0.000	8.000	16.000	138.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.419+00	\N	Lemon
44e5597d-692b-44c2-8549-670086c5237b	Лимонный сок	\N	{"tsp": 5, "tbsp": 15}	22.000	0.400	6.900	0.200	0.000	2.500	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.050	0.000	0.000	0.000	39.000	0.000	0.000	0.000	6.000	0.000	0.000	8.000	103.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.427+00	\N	Lemon juice
874cf0f6-362c-48b4-b099-36915c5ec35b	Лайм	\N	{"piece": 67}	30.000	0.700	10.500	0.200	2.800	1.700	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.050	0.000	8.000	0.000	29.000	0.000	0.000	0.000	33.000	0.000	6.000	18.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.436+00	\N	Lime
5086c70a-eb85-4e61-aa8d-e81ce1167a03	Помидор	\N	{"piece": 123}	18.000	0.900	3.900	0.200	1.200	2.600	0.000	0.000	0.000	0.000	0.000	42.000	0.040	0.000	0.000	0.000	0.080	0.000	15.000	0.000	14.000	0.000	0.500	7.900	10.000	0.300	11.000	0.000	237.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.444+00	\N	Tomato
4b1367e5-0a83-488b-a8d3-8ed4aa7073ea	Черри помидоры	\N	{}	18.000	0.900	3.900	0.200	1.200	2.600	0.000	0.000	0.000	0.000	0.000	42.000	0.000	0.000	0.000	0.000	0.080	0.000	15.000	0.000	14.000	0.000	0.500	0.000	10.000	0.300	11.000	0.000	237.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.456+00	\N	Cherry tomatoes
c88015b8-3085-4148-be53-d4310f21b23d	Огурец	\N	{"piece": 200}	15.000	0.700	3.600	0.100	0.500	1.700	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.040	0.000	7.000	0.000	2.800	0.000	0.000	16.400	16.000	0.300	13.000	0.000	147.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.465+00	\N	Cucumber
68c6aa8c-825f-4f27-8cec-5a2726e2d46e	Красный лук	\N	{"piece": 110}	40.000	1.100	9.300	0.100	1.700	4.200	0.000	0.000	0.000	0.000	0.000	0.000	0.050	0.000	0.000	0.000	0.120	0.000	19.000	0.000	7.400	0.000	0.000	0.000	23.000	0.200	10.000	0.000	146.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.473+00	\N	Red onion
25864bc1-ebe0-4b33-92c4-8e81f479a18d	Репчатый лук	\N	{"piece": 110}	40.000	1.100	9.300	0.100	1.700	4.200	0.000	0.000	0.000	0.000	0.000	0.000	0.050	0.000	0.000	0.000	0.120	0.000	19.000	0.000	7.400	0.000	0.000	0.000	23.000	0.200	10.000	0.000	146.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.482+00	\N	Onion
95ff2fa0-ff52-4961-836a-6984ba7add98	Чеснок	\N	{"clove": 3}	149.000	6.400	33.100	0.500	2.100	1.000	0.000	0.000	0.000	0.000	0.000	0.000	0.200	0.000	0.000	0.000	1.200	0.000	3.000	0.000	31.000	0.000	0.000	0.000	181.000	0.000	25.000	153.000	0.000	0.000	0.000	1.700	14.200	0.000	2026-09-20 20:06:51.49+00	\N	Garlic
de9ff794-b346-47ca-9383-df0bfba09478	Имбирь	\N	{}	80.000	1.800	17.800	0.800	2.000	1.700	0.000	0.000	0.000	0.000	0.000	0.000	0.030	0.030	0.750	0.000	0.200	0.000	0.000	0.000	5.000	0.000	0.000	0.000	16.000	0.600	43.000	0.000	415.000	0.300	0.000	0.200	0.000	0.000	2026-09-20 20:06:51.498+00	\N	Ginger
d91abeb4-8b86-4567-85e1-b3c576bf68bc	Шпинат	\N	{"cup": 30}	23.000	2.900	3.600	0.400	2.200	0.400	0.000	0.000	0.000	0.000	0.000	469.000	0.080	0.190	0.700	0.000	0.200	0.000	194.000	0.000	28.000	0.000	2.000	483.000	99.000	2.700	79.000	49.000	558.000	0.500	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.508+00	\N	Spinach
66eb1a53-79a4-4a4c-8bb8-25fe823055c6	Салат ромэн	\N	{}	17.000	1.200	3.300	0.300	2.100	1.200	0.000	0.000	0.000	0.000	0.000	436.000	0.060	0.000	0.000	0.000	0.000	0.000	136.000	0.000	4.000	0.000	0.000	103.000	33.000	1.000	14.000	0.000	247.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.517+00	\N	Romaine lettuce
7d807b7e-f17a-427e-bb75-6200cb919578	Смесь салатной зелени	\N	{"cup": 30}	20.000	1.800	3.300	0.300	1.800	1.000	0.000	0.000	0.000	0.000	0.000	400.000	0.000	0.000	0.000	0.000	0.000	0.000	120.000	0.000	15.000	0.000	0.000	200.000	40.000	1.000	15.000	0.000	250.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.526+00	\N	Mixed greens
2c43a12f-f532-4df7-b55b-6c312d689340	Брокколи	\N	{}	34.000	2.800	6.600	0.400	2.600	1.700	0.000	0.000	0.000	0.000	0.000	31.000	0.070	0.120	0.000	0.000	0.000	0.000	63.000	0.000	89.000	0.000	0.800	102.000	47.000	0.700	21.000	0.000	316.000	0.400	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.536+00	\N	Broccoli
33e1b06a-65c1-4277-a26b-89a1964e47a5	Спаржа	\N	{}	20.000	2.200	3.900	0.100	2.100	1.900	0.000	0.000	0.000	0.000	0.000	38.000	0.140	0.140	0.000	0.000	0.000	0.000	52.000	0.000	5.600	0.000	1.100	41.600	24.000	2.100	14.000	0.000	202.000	0.500	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.543+00	\N	Asparagus
82090119-5b09-4c87-8af4-b0c63ab75a3a	Болгарский перец	\N	{"piece": 119}	31.000	1.000	6.000	0.300	2.100	4.200	0.000	0.000	0.000	0.000	0.000	157.000	0.000	0.000	0.000	0.000	0.290	0.000	46.000	0.000	128.000	0.000	1.600	4.900	7.000	0.400	12.000	0.000	211.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.553+00	\N	Bell pepper
12e0c381-f45a-4d26-866f-47012609b45e	Морковь	\N	{"piece": 61}	41.000	0.900	9.600	0.200	2.800	4.700	0.000	0.000	0.000	0.000	0.000	835.000	0.000	0.000	0.000	0.000	0.140	0.000	19.000	0.000	5.900	0.000	0.660	13.200	33.000	0.300	12.000	0.000	320.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.561+00	\N	Carrot
d18c6c8f-8df0-4d7d-b248-8a6099210cdc	Сельдерей	\N	{"piece": 40}	16.000	0.700	3.000	0.200	1.600	1.300	0.000	0.000	0.000	0.000	0.000	22.000	0.000	0.000	0.000	0.000	0.000	0.000	36.000	0.000	3.100	0.000	0.000	29.300	40.000	0.200	11.000	0.000	260.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.57+00	\N	Celery
a3bdab62-9e64-4377-8761-f8bcd0cb91d2	Шампиньоны	\N	{}	22.000	3.100	3.300	0.300	1.000	2.000	0.000	0.000	0.000	0.000	0.000	0.000	0.080	0.400	3.600	1.500	0.000	0.000	17.000	0.000	0.000	0.200	0.000	0.000	3.000	0.500	9.000	86.000	318.000	0.500	0.300	0.000	9.300	0.000	2026-09-20 20:06:51.577+00	\N	Mushroom
579b7337-d801-4dc9-b599-508912450440	Гриб портобелло	\N	{"piece": 84}	22.000	2.500	4.100	0.400	1.500	2.000	0.000	0.000	0.000	0.000	0.000	0.000	0.060	0.200	4.900	1.400	0.000	0.000	16.000	0.000	0.000	0.200	0.000	0.000	3.000	0.400	9.000	90.000	364.000	0.500	0.400	0.000	9.000	0.000	2026-09-20 20:06:51.587+00	\N	Portobello mushroom
26bc159e-d6a8-49ef-abf9-9e3b4d8b87a5	Оливки каламата	\N	{}	115.000	0.800	6.300	10.700	3.200	0.000	1.400	0.000	1556.000	0.000	0.000	17.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	1.700	0.000	88.000	3.300	22.000	0.000	0.000	0.000	0.140	0.000	0.000	0.000	2026-09-20 20:06:51.594+00	\N	Kalamata olives
43cbf2d3-7165-438e-9d6a-9df5afc83ec4	Базилик	\N	{}	23.000	3.200	2.700	0.600	1.600	0.300	0.000	0.000	0.000	0.000	0.000	264.000	0.030	0.080	0.000	0.000	0.160	0.000	68.000	0.000	18.000	0.000	0.800	415.000	177.000	3.200	64.000	0.000	295.000	0.800	0.000	1.100	0.000	0.000	2026-09-20 20:06:51.604+00	\N	Basil
73b9bf7c-b87b-4892-a32c-089c2e103d00	Петрушка	\N	{}	36.000	3.000	6.300	0.800	3.300	0.900	0.000	0.000	0.000	0.000	0.000	421.000	0.090	0.100	0.000	0.000	0.000	0.000	152.000	0.000	133.000	0.000	0.750	1640.000	138.000	6.200	50.000	0.000	554.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.612+00	\N	Parsley
6b910dcf-9133-4810-9078-33961d0c63e2	Укроп	\N	{}	43.000	3.500	7.000	1.100	2.100	0.000	0.000	0.000	0.000	0.000	0.000	386.000	0.060	0.300	0.000	0.000	0.000	0.000	150.000	0.000	85.000	0.000	0.000	0.000	208.000	6.600	55.000	0.000	738.000	0.000	0.000	1.300	0.000	0.000	2026-09-20 20:06:51.621+00	\N	Dill
b8a3e0fb-6d4e-4139-8751-8e1773b0d2bc	Зелёный лук (шнитт)	\N	{}	30.000	3.300	4.400	0.700	2.500	1.900	0.000	0.000	0.000	0.000	0.000	218.000	0.080	0.110	0.000	0.000	0.000	0.000	105.000	0.000	58.100	0.000	0.000	213.000	92.000	1.600	42.000	0.000	296.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.63+00	\N	Chives
f0a44300-564a-40b0-8990-7d5089ff1d3a	Кинза	\N	{}	23.000	2.100	3.700	0.500	2.800	0.900	0.000	0.000	0.000	0.000	0.000	337.000	0.070	0.160	0.000	0.000	0.000	0.000	62.000	0.000	27.000	0.000	0.000	310.000	67.000	1.800	26.000	0.000	521.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.639+00	\N	Cilantro
0c9d3ca9-2cfc-438e-88e2-493fd7fe5778	Зелёный лук (перо)	\N	{}	32.000	1.800	7.300	0.200	2.600	2.300	0.000	0.000	0.000	0.000	0.000	386.000	0.060	0.080	0.000	0.000	0.000	0.000	64.000	0.000	18.800	0.000	0.000	207.000	72.000	1.500	20.000	0.000	276.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.646+00	\N	Spring onion
a75ae202-b7d5-4882-be33-0635029521c2	Банан	\N	{"piece": 118}	89.000	1.100	22.800	0.300	2.600	12.200	0.000	0.000	0.000	0.000	0.000	0.000	0.030	0.070	0.700	0.000	0.400	0.000	20.000	0.000	8.700	0.000	0.000	0.000	5.000	0.300	27.000	0.000	358.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.657+00	\N	Banana
a7ef29ff-a2c2-4861-98e4-64aa261fb8c8	Смесь ягод	\N	{"cup": 150}	50.000	0.800	12.000	0.400	3.500	7.500	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	20.000	0.000	30.000	0.000	0.600	15.000	20.000	0.500	15.000	0.000	130.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.668+00	\N	Mixed berries
c40b9b15-b3de-4f89-ade2-869397a239a5	Черника	\N	{"cup": 148}	57.000	0.700	14.500	0.300	2.400	10.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.050	0.000	0.000	0.000	9.700	0.000	0.600	19.300	6.000	0.300	6.000	0.000	77.000	0.000	0.000	0.300	0.000	0.000	2026-09-20 20:06:51.678+00	\N	Blueberries
4ca6a536-5d47-415c-bce2-daf615e81f70	Клубника	\N	{"cup": 152}	32.000	0.700	7.700	0.300	2.000	4.900	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	24.000	0.000	59.000	0.000	0.300	2.200	16.000	0.400	13.000	0.000	153.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.688+00	\N	Strawberries
6d9cb726-a970-4304-8478-7a743b3ffc3e	Яблоко	\N	{"piece": 182}	52.000	0.300	13.800	0.200	2.400	10.400	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.040	0.000	0.000	0.000	4.600	0.000	0.000	2.200	6.000	0.100	5.000	0.000	107.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.696+00	\N	Apple
c59a079b-bdf8-4fd9-a872-0669e95feab4	Манго	\N	{"piece": 200}	60.000	0.800	15.000	0.400	1.600	13.700	0.000	0.000	0.000	0.000	0.000	54.000	0.000	0.000	0.000	0.000	0.120	0.000	43.000	0.000	36.400	0.000	0.900	4.200	11.000	0.200	10.000	0.000	168.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.706+00	\N	Mango
7a3fa257-87ed-4a89-9c55-b658a1e0acbf	Тыква	\N	{}	26.000	1.000	6.500	0.100	0.500	2.800	0.000	0.000	0.000	0.000	0.000	8513.000	0.000	0.000	0.000	0.000	0.000	0.000	16.000	0.000	9.000	0.000	1.100	1.100	21.000	0.800	12.000	0.000	340.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.716+00	\N	Pumpkin
d7a92616-af91-4afe-ab01-042e794e15b4	Капуста	\N	{}	25.000	1.300	5.800	0.100	2.500	3.200	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.120	0.000	43.000	0.000	36.600	0.000	0.000	76.000	40.000	0.500	12.000	0.000	170.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.724+00	\N	Cabbage
6e8198f8-5655-44a3-8fb6-c08c8bdfeb37	Каперсы	\N	{"tsp": 4}	23.000	2.400	4.900	0.900	3.200	0.400	0.000	0.000	2960.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	4.000	0.000	0.000	24.600	40.000	1.700	33.000	0.000	0.000	0.000	0.000	0.000	0.000	0.000	2026-09-20 20:06:51.733+00	\N	Capers
\.


--
-- Data for Name: ingredient_tag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ingredient_tag (ingredient_id, tag_id) FROM stdin;
1d8538a5-2082-4d35-99bf-843ed8c18e3c	badc51b5-2b17-40cf-9ddc-7f109efda359
c77109ba-d9d5-487e-be10-9134ca9ff4b6	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
2b6db454-cfdd-4105-bbb7-75b71fa8eb27	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
8a2618a7-1fb5-4fd4-9326-62336adc3508	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
6665d4dd-2e53-4c42-a259-247ea6adcf35	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
7049f9f9-6892-403c-9915-76c67abd77b6	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
d2ae29d7-17a4-40db-89e8-b20c8f698488	f9091468-45e9-47cc-9762-74b2609edc08
8e80d460-222c-4969-83c7-7d3bd8ef2979	13a75c7a-6e7d-41c9-89f6-562f21da2d95
8ab706f2-1c77-478a-9e31-e1d04f27224c	13a75c7a-6e7d-41c9-89f6-562f21da2d95
80b87ca3-1251-4761-a315-e866c230c08b	77b878e7-1631-4fff-b12a-03001d07ef4a
b53e5343-7e07-4574-8d72-43cdf0187014	13a75c7a-6e7d-41c9-89f6-562f21da2d95
b75a7fb9-17cd-4bd3-8463-368f0312e201	13a75c7a-6e7d-41c9-89f6-562f21da2d95
e489a9b7-4df7-4d1c-b736-6fee915e9ae7	13a75c7a-6e7d-41c9-89f6-562f21da2d95
f6576856-fb2a-4789-a7a8-0daef7f9949f	13a75c7a-6e7d-41c9-89f6-562f21da2d95
e0c7a66e-0716-43c1-8027-b1e721108d5b	13a75c7a-6e7d-41c9-89f6-562f21da2d95
645bcd1c-a04a-4498-9541-21a9ea7d3447	13a75c7a-6e7d-41c9-89f6-562f21da2d95
82a7642e-d453-4360-ae0c-de1328d37580	13a75c7a-6e7d-41c9-89f6-562f21da2d95
6d89dc43-e48b-4005-bbfe-363cb552d0f5	13a75c7a-6e7d-41c9-89f6-562f21da2d95
bb7cae1c-9ed6-43cd-9b3f-3e5b8c148f88	13a75c7a-6e7d-41c9-89f6-562f21da2d95
6cf8dd84-bc6e-4e68-878c-6c115bb36862	13a75c7a-6e7d-41c9-89f6-562f21da2d95
64493b76-b118-4fae-b92e-be8f70bc2b4c	fff848ab-d932-4226-b903-6dd676a157e9
aa53b8ba-121c-4cde-af29-a3a0be157270	fff848ab-d932-4226-b903-6dd676a157e9
8ca5c6e4-0495-45c9-b0d0-6f46a1b5f51f	fff848ab-d932-4226-b903-6dd676a157e9
e6887371-382e-4c0c-b841-1a40e6c9f897	fff848ab-d932-4226-b903-6dd676a157e9
ebce98c5-24da-49a1-97d3-553bf577ab4e	fff848ab-d932-4226-b903-6dd676a157e9
310f681b-20dc-46f5-9fe0-8876bf5cdb37	fff848ab-d932-4226-b903-6dd676a157e9
b4533f1f-9c8e-47fe-9341-1f3e9e370b83	fff848ab-d932-4226-b903-6dd676a157e9
50f81ce7-3738-474e-b2aa-7abc41f3e299	fff848ab-d932-4226-b903-6dd676a157e9
9a77127b-1ca1-415a-a7da-e55c282d1ed5	fff848ab-d932-4226-b903-6dd676a157e9
9a77127b-1ca1-415a-a7da-e55c282d1ed5	badc51b5-2b17-40cf-9ddc-7f109efda359
57a086d7-a00f-4e41-84ac-e6a0cc2e5663	fff848ab-d932-4226-b903-6dd676a157e9
a9a1bad9-4eca-43e7-b6d7-ee335e2702c8	fff848ab-d932-4226-b903-6dd676a157e9
be39aa1e-2b5d-4da0-bc4e-f05b09216616	fff848ab-d932-4226-b903-6dd676a157e9
be39aa1e-2b5d-4da0-bc4e-f05b09216616	77b878e7-1631-4fff-b12a-03001d07ef4a
9926a47f-28d3-46bc-90bd-b22c64193ab3	fff848ab-d932-4226-b903-6dd676a157e9
0e4d9d9a-37e9-482b-89dd-2ab597222cc7	30868e77-77e3-4d0e-8d5d-7533373c1c7f
457f1060-ef40-4a5b-a2df-85f2e1d7a435	77b878e7-1631-4fff-b12a-03001d07ef4a
ae3e9146-ec42-4d2b-96da-07245ad8b468	77b878e7-1631-4fff-b12a-03001d07ef4a
3837182b-4acc-401b-beb5-0db0de087bc3	b0ce49d7-5fca-4864-a265-0d6368cdc105
f3244cab-948a-43e9-9d33-514996ddee16	badc51b5-2b17-40cf-9ddc-7f109efda359
583d36ed-70c5-42d4-a2b3-87bc4e4b8a8e	badc51b5-2b17-40cf-9ddc-7f109efda359
583d36ed-70c5-42d4-a2b3-87bc4e4b8a8e	13a75c7a-6e7d-41c9-89f6-562f21da2d95
\.


--
-- Data for Name: my_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.my_item (id, user_id, name, ctime, utime) FROM stdin;
\.


--
-- Data for Name: my_session; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.my_session (user_id, token, fcm_token, user_agent, ip, impersonated_by, ctime, utime) FROM stdin;
d773a49e-5792-4088-a77d-8ab0a5d377fa	d773a49e-5792-4088-a77d-8ab0a5d377fa_$2b$10$rfEUnZTJQFNQqCYzlohff./Bcx7trwKbPa7nf2Bt.uHYwkddHewLC	\N	okhttp/4.9.2	192.168.3.8	\N	2026-09-20 23:03:48.257+00	2026-09-20 23:03:49.285+00
20fe47e7-bce3-4903-ae40-2c2e2b0a2ea2	20fe47e7-bce3-4903-ae40-2c2e2b0a2ea2_$2b$10$cC4K76vNcEbfzw2.3ax1Pe/9Q2v.zFUndtp3bIdcDeWCXaaRIwMXC	\N	node	192.168.3.3	\N	2026-09-20 20:06:50.223+00	2026-09-20 20:06:52.972+00
20fe47e7-bce3-4903-ae40-2c2e2b0a2ea2	20fe47e7-bce3-4903-ae40-2c2e2b0a2ea2_$2b$10$RfOi.5Rg10Kqnw.YTzM4WesMqNb900oHXxKTUazZAQ7DCm/YjYvPa	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	127.0.0.1	\N	2026-09-17 07:50:54.559+00	2026-09-20 22:03:56.059+00
20fe47e7-bce3-4903-ae40-2c2e2b0a2ea2	20fe47e7-bce3-4903-ae40-2c2e2b0a2ea2_$2b$10$WUrCDs1mbH43la46C48IN.8Iq5dS7jFsjZacal1TH2GakeTe14Xoi	\N	curl/8.5.0	127.0.0.1	\N	2026-09-08 15:54:27.587+00	\N
e4af892f-a393-42f3-80d7-c46e4c592152	e4af892f-a393-42f3-80d7-c46e4c592152_$2b$10$cXbNMPHy99A2ZqhoK3Nm9uCl9L7Rb7AZroqWKmg/3i04nmn/4QcDO	\N	okhttp/4.9.2	192.168.3.8	\N	2026-09-20 20:11:03.58+00	2026-09-20 20:11:36.921+00
e4af892f-a393-42f3-80d7-c46e4c592152	e4af892f-a393-42f3-80d7-c46e4c592152_$2b$10$sYSyAIA1XzByvV1lGLG2UeQ/o0mUn7/rfdnrejV/KjWumYTXfivMa	\N	okhttp/4.9.2	192.168.3.8	\N	2026-09-20 20:33:01.284+00	2026-09-20 20:33:28.359+00
e4af892f-a393-42f3-80d7-c46e4c592152	e4af892f-a393-42f3-80d7-c46e4c592152_$2b$10$ImXLSlHDEh62UwrtO3a4UOJ5H7RD2taRytJUDG/kjSnDOVC6CJxce	\N	okhttp/4.9.2	192.168.3.8	\N	2026-09-20 15:48:08.952+00	\N
e4af892f-a393-42f3-80d7-c46e4c592152	e4af892f-a393-42f3-80d7-c46e4c592152_$2b$10$m2iH/mpwTkjYwSeY6USqF.YTeDp.j1qvHGtSzVXyu.jyTH7UhAiQ2	\N	okhttp/4.9.2	192.168.3.8	\N	2026-09-20 15:56:49.657+00	\N
e4af892f-a393-42f3-80d7-c46e4c592152	e4af892f-a393-42f3-80d7-c46e4c592152_$2b$10$kS0mrJo8zILeJLUj/ytO2u.C3J/cxj8k/612O1XGpmUILfWVJY4P2	\N	okhttp/4.9.2	192.168.3.8	\N	2026-09-20 15:57:58.275+00	2026-09-20 16:21:43.616+00
e4af892f-a393-42f3-80d7-c46e4c592152	e4af892f-a393-42f3-80d7-c46e4c592152_$2b$10$Xe5Xs6SwKCaPl2MwQP6OpeEEh7FKhR8l1HN3uvrhNlxzRK2NPEPx2	\N	okhttp/4.9.2	192.168.3.8	\N	2026-09-20 19:02:39.773+00	\N
\.


--
-- Data for Name: my_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.my_user (id, name, surname, email, password, role, ctime, utime, active, reset_token, reset_token_expires, sex, age, height_cm, weight_kg, target_weight_kg, activity_level, goal_type, manual_calorie_target, manual_macro_split, preferences) FROM stdin;
2a1ac043-17fb-4c11-adee-9265057e6575	\N	\N	test@gm.com	$2b$10$D.IwN70jw7JvAvjVC8.qMu1W4kXYERpwo0aEs.Qhxa6/c5xQhv2ce	user	2026-09-06 22:12:30.176+00	\N	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{}
2c67ef12-7098-42f4-ad9e-03f6262c9c67	Fgg	\N	fhh@gmail.cim	$2b$10$XszjqOtTfK/H3sJWKwshA.K8rUqdU5wdGJrtwoESbPS9cIbkWeYvG	user	2026-09-06 22:16:40.033+00	2026-09-06 22:17:19.509+00	t	\N	\N	female	39	179.0	120.0	95.0	sedentary	lose-weight	\N	\N	{"units": "imperial", "allergies": ["tree nuts", "peanuts", "fish"], "dietaryTags": ["vegetarian", "gluten-free"], "favoriteCuisines": [], "dislikedIngredientIds": []}
20fe47e7-bce3-4903-ae40-2c2e2b0a2ea2	\N	\N	admin@nutriflow.local	$2b$10$0LyTA6JS./P3rY65LSBqA.RhsAji01eSiML3wINoR92e23SOQhj5e	super_admin	2026-09-08 15:54:27.583+00	\N	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{}
e4af892f-a393-42f3-80d7-c46e4c592152	Ммии	\N	gyk088@gmail.com	$2b$10$XxQtJ4gR9ZXBnLcGOgo93OHRRlxI8paoic1VBNmL52AkCuXRoUKgi	super_admin	2026-09-20 15:48:08.948+00	2026-09-20 22:03:56.065+00	t	\N	\N	female	35	180.0	119.0	60.0	sedentary	lose-weight	\N	\N	{"units": "metric", "allergies": [], "dietaryTags": [], "favoriteCuisines": [], "dislikedIngredientIds": []}
d773a49e-5792-4088-a77d-8ab0a5d377fa	Андрей	Жук	azuk07700@gmail.com	\N	user	2026-09-20 23:03:33.837+00	\N	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{}
\.


--
-- Data for Name: recipe; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipe (id, name_ru, description_ru, image_url, servings, ctime, utime, cook_time_ru, steps_ru, name_en, description_en, steps_en, cook_time_en) FROM stdin;
1b55a005-6344-4714-9aa7-97837cca2086	Яйца Бенедикт	Яйца-пашот и канадский бекон на поджаренном английском маффине, политые сливочным соусом голландез.	https://images.unsplash.com/photo-1608039755401-742074f0548d?w=1200	2	2026-09-20 20:06:51.885+00	\N	25 минут	1. Разрежьте и поджарьте английские маффины.\n2. Разогрейте канадский бекон на сковороде до лёгкой румяности.\n3. Отварите яйца-пашот в слабо кипящей воде до готовности белка.\n4. Взбейте желтки с лимонным соком, постепенно вливая растопленное масло, чтобы получить соус голландез.\n5. Соберите маффин, бекон и яйцо-пашот, полейте соусом и посыпьте зелёным луком.	Eggs Benedict	Poached eggs and Canadian bacon on a toasted English muffin, finished with a buttery hollandaise.	1. Split and toast the English muffins.\n2. Warm the Canadian bacon in a pan until lightly browned.\n3. Poach the eggs in gently simmering water until whites are set.\n4. Whisk egg yolks with lemon juice, then slowly whisk in melted butter to make hollandaise.\n5. Stack muffin, bacon and poached egg; spoon over hollandaise and top with chives.	25 minutes
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	Тост с авокадо и яйцом	Нежное пюре из авокадо на поджаренном хлебе на закваске, сверху — яйцо-глазунья и хлопья чили.	https://images.unsplash.com/photo-1525351484163-7529414344d8?w=1200	1	2026-09-20 20:06:51.742+00	\N	10 минут	1. Поджарьте ломтики хлеба на закваске до золотистой корочки.\n2. Разомните авокадо с лимонным соком, солью и перцем.\n3. Обжарьте яйцо на оливковом масле на среднем огне, пока белок не схватится.\n4. Намажьте авокадо на тост, сверху выложите яйцо и посыпьте хлопьями чили.	Avocado Toast with Egg	Creamy smashed avocado on toasted sourdough, topped with a soft fried egg and chili flakes.	1. Toast the sourdough slices until golden and crisp.\n2. Mash the avocado with lemon juice, salt and pepper.\n3. Fry the egg in olive oil over medium heat until the white is set.\n4. Spread avocado over the toast, top with the fried egg and chili flakes.	10 minutes
90627aea-d9f9-46ff-bd2a-21112d6feaad	Греческий йогурт с ягодами	Густой греческий йогурт, выложенный слоями с ягодами, мёдом и хрустящей гранолой.	https://images.unsplash.com/photo-1488477181946-6428a0291777?w=1200	1	2026-09-20 20:06:51.774+00	\N	5 минут	1. Выложите греческий йогурт в миску.\n2. Добавьте сверху ягоды и полейте мёдом.\n3. Посыпьте гранолой.	Greek Yogurt with Berries	Thick Greek yogurt layered with mixed berries, honey and crunchy granola.	1. Spoon the Greek yogurt into a bowl.\n2. Top with mixed berries and a drizzle of honey.\n3. Finish with a sprinkle of granola.	5 minutes
d67e7969-8efe-4e9a-82be-9ff4d85fc571	Овсянка с бананом	Тёплая овсянка, сваренная на молоке, с размятым бананом, корицей и обжаренными грецкими орехами.	https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=1200	1	2026-09-20 20:06:51.797+00	\N	15 минут	1. Варите овсяные хлопья на молоке на слабом огне, изредка помешивая.\n2. Разомните половину банана и вмешайте в овсянку, оставшуюся часть нарежьте для украшения.\n3. Переложите в миску, украсьте ломтиками банана, корицей, мёдом и орехами.	Banana Oatmeal	Warm rolled oats simmered with milk, mashed banana, cinnamon and toasted walnuts.	1. Simmer oats in milk over medium-low heat, stirring occasionally.\n2. Mash half the banana into the oats; slice the rest for topping.\n3. Spoon into a bowl, top with banana slices, cinnamon, honey and walnuts.	15 minutes
71551f3d-b1e1-45f4-ab74-266b7479c55d	Омлет со шпинатом	Пышный омлет из трёх яиц с тушёным шпинатом и раскрошенной фетой.	https://images.unsplash.com/photo-1510693206972-df098062cb71?w=1200	1	2026-09-20 20:06:51.822+00	\N	13 минут	1. Взбейте яйца с щепоткой соли и перца.\n2. Обжарьте шпинат на оливковом масле на среднем огне около минуты, пока не завянет.\n3. Влейте яйца и готовьте, пока омлет почти не схватится.\n4. Посыпьте фетой, сложите пополам и переложите на тарелку.	Spinach Omelette	Fluffy three-egg omelette folded with wilted spinach and crumbled feta.	1. Whisk the eggs with a pinch of salt and pepper.\n2. Wilt the spinach in olive oil over medium heat, about 1 minute.\n3. Pour in the eggs and cook until mostly set.\n4. Sprinkle with feta, fold in half and slide onto a plate.	13 minutes
fd48d17b-86df-4000-9799-6933b6873f81	Творожные панкейки	Высокобелковые панкейки из творога, овсянки и банана — без муки.	https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=1200	2	2026-09-20 20:06:51.841+00	\N	20 минут	1. Взбейте в блендере творог, яйца, овсянку, половину банана и разрыхлитель до однородности.\n2. Дайте тесту постоять 5 минут.\n3. Растопите масло на антипригарной сковороде и вылейте небольшие порции теста.\n4. Обжарьте с каждой стороны до золотистого цвета.\n5. Подавайте стопкой, украсив оставшимся нарезанным бананом.	Cottage Cheese Pancakes	High-protein pancakes made with cottage cheese, oats and banana — no flour needed.	1. Blend the cottage cheese, eggs, oats, half the banana and baking powder until smooth.\n2. Rest the batter for 5 minutes.\n3. Melt butter in a nonstick pan and pour small rounds of batter.\n4. Cook each side until golden.\n5. Serve stacked with the remaining banana sliced on top.	20 minutes
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	Бейгл с копчёным лососем	Поджаренный бейгл со сливочным сыром, копчёным лососем, каперсами и красным луком.	https://images.unsplash.com/photo-1592483648228-9c1a30651052?w=1200	1	2026-09-20 20:06:51.863+00	\N	10 минут	1. Разрежьте и поджарьте бейгл.\n2. Щедро намажьте сливочный сыр на обе половинки.\n3. Выложите слоями копчёный лосось, тонко нарезанный красный лук и каперсы.\n4. Посыпьте рубленым укропом.	Smoked Salmon Bagel	A toasted bagel piled with cream cheese, smoked salmon, capers and red onion.	1. Slice and toast the bagel.\n2. Spread cream cheese generously on both halves.\n3. Layer smoked salmon, thin red onion slices and capers.\n4. Finish with chopped dill.	10 minutes
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	Ролл с курицей «Цезарь»	Жареная курица, хрустящий салат ромэн и пармезан, завёрнутые в мягкую тортилью с соусом «Цезарь».	https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=1200	1	2026-09-20 20:06:51.907+00	\N	20 минут	1. Обжарьте куриную грудку на оливковом масле до готовности.\n2. Нарежьте курицу и перемешайте с салатом ромэн, пармезаном и соусом «Цезарь».\n3. Наполните тортилью начинкой и плотно сверните.	Chicken Caesar Wrap	Grilled chicken, crisp romaine and parmesan rolled into a soft tortilla with Caesar dressing.	1. Pan-sear the chicken breast in olive oil until cooked through.\n2. Slice the chicken and toss with romaine, parmesan and Caesar dressing.\n3. Fill the tortilla with the mixture and roll tightly.	20 minutes
74e74a2f-3579-4619-a911-fd5af69f6fd7	Сэндвич с курицей и авокадо	Жареная куриная грудка с пюре из авокадо, помидором и салатом на поджаренном хлебе.	https://images.unsplash.com/photo-1553909489-cd47e0907980?w=1200	1	2026-09-20 20:06:51.929+00	\N	20 минут	1. Приправьте и обжарьте куриную грудку до готовности.\n2. Поджарьте хлеб и разомните авокадо на одном ломтике.\n3. Выложите курицу, помидор и салат, намажьте майонез на второй ломтик и соберите сэндвич.	Avocado Chicken Sandwich	Grilled chicken breast with mashed avocado, tomato and lettuce on toasted bread.	1. Season and grill the chicken breast until cooked through.\n2. Toast the bread and mash the avocado on one slice.\n3. Layer chicken, tomato and lettuce, spread mayonnaise on the other slice, and close the sandwich.	20 minutes
8f48e7b7-611c-428b-899a-a1ca55f41779	Овощной киш	Домашняя песочная основа с начинкой из яиц, шпината, болгарского перца и расплавленного чеддера.	https://images.unsplash.com/photo-1584949091598-c31daaaa4aa9?w=1200	6	2026-09-20 20:06:51.951+00	\N	55 минут	1. Смешайте муку с холодным маслом в тесто, распределите по форме для тарта и охладите.\n2. Выпеките основу вслепую при 190°C.\n3. Обжарьте лук, болгарский перец и шпинат до мягкости.\n4. Взбейте яйца с молоком, вмешайте овощи и чеддер, вылейте в основу.\n5. Выпекайте, пока начинка не схватится и не подрумянится.	Veggie Quiche	A buttery homemade crust filled with eggs, spinach, bell pepper and melted cheddar.	1. Combine flour and cold butter into a dough, press into a tart pan and chill.\n2. Blind-bake the crust at 190°C (375°F).\n3. Sauté onion, bell pepper and spinach until softened.\n4. Whisk eggs with milk, stir in the vegetables and cheddar, then pour into the crust.\n5. Bake until the filling is set and golden.	55 minutes
a8b44445-3f32-4ab8-88e0-34c72fc1671b	Греческий салат	Свежий огурец, помидор и красный лук с фетой, оливками каламата и оливковой заправкой.	https://images.unsplash.com/photo-1540420773420-3366772f4999?w=1200	2	2026-09-20 20:06:51.975+00	\N	15 минут	1. Нарежьте огурец и помидор кусочками, красный лук — тонкими кольцами.\n2. Смешайте в миске с оливками, сверху выложите кусок феты.\n3. Полейте оливковым маслом, приправьте орегано, солью и перцем.	Greek Salad	Crisp cucumber, tomato and red onion with feta, kalamata olives and a bright olive oil dressing.	1. Chop the cucumber and tomato into chunks; thinly slice the red onion.\n2. Combine in a bowl with olives and a block of feta on top.\n3. Drizzle with olive oil and season with oregano, salt and pepper.	15 minutes
5f660db5-8f5d-4401-a53c-563ff59dc677	Салат «Цезарь»	Классический салат ромэн, хрустящие гренки и пармезан в соусе «Цезарь», по желанию — с жареной курицей.	https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=1200	2	2026-09-20 20:06:51.999+00	\N	18 минут	1. Обжарьте куриную грудку на оливковом масле до готовности, затем нарежьте.\n2. Нарежьте салат ромэн и заправьте соусом «Цезарь».\n3. Посыпьте гренками, пармезаном и выложите курицу.	Caesar Salad	Classic romaine, crunchy croutons and shaved parmesan tossed in Caesar dressing, with optional grilled chicken.	1. Sear the chicken breast in olive oil until cooked through, then slice.\n2. Chop the romaine and toss with Caesar dressing.\n3. Top with croutons, shaved parmesan and sliced chicken.	18 minutes
6cf92b55-c01f-4e77-a088-81d8bab48af8	Салат с киноа	Рассыпчатая киноа с огурцом, черри помидорами, нутом и фетой в лимонно-оливковой заправке.	https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200	2	2026-09-20 20:06:52.023+00	\N	25 минут	1. Промойте киноа и отварите в воде до готовности, затем остудите.\n2. Нарежьте огурец кубиками, черри помидоры разрежьте пополам.\n3. Смешайте киноа, огурец, помидоры, нут и фету.\n4. Заправьте оливковым маслом и лимонным соком, перемешайте.	Quinoa Salad	Fluffy quinoa with cucumber, cherry tomatoes, chickpeas and feta in a lemon-olive oil dressing.	1. Rinse and simmer quinoa in water until fluffy, then cool.\n2. Dice the cucumber and halve the cherry tomatoes.\n3. Combine quinoa, cucumber, tomatoes, chickpeas and feta.\n4. Dress with olive oil and lemon juice, then toss.	25 minutes
76af319d-ef28-454e-8e8b-f1d8305bafc4	Салат с тунцом	Тунец кусочками с сельдереем и красным луком в лёгкой майонезной заправке на смеси зелени.	https://images.unsplash.com/photo-1604909052743-94e838986d24?w=1200	1	2026-09-20 20:06:52.05+00	\N	10 минут	1. Слейте жидкость с тунца и разомните его вилкой в миске.\n2. Мелко нарежьте сельдерей и красный лук, смешайте с тунцом, майонезом и лимонным соком.\n3. Подавайте на подушке из смеси зелени.	Tuna Salad	Flaked tuna with celery and red onion in a light mayonnaise dressing over mixed greens.	1. Drain the tuna and flake it into a bowl.\n2. Finely dice celery and red onion, then mix with tuna, mayonnaise and lemon juice.\n3. Serve over a bed of mixed greens.	10 minutes
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	Салат «Капрезе»	Нарезанный помидор и свежая моцарелла, выложенные слоями с базиликом, оливковым маслом и бальзамическим соусом.	https://images.unsplash.com/photo-1608897013039-887f21d8c804?w=1200	2	2026-09-20 20:06:52.074+00	\N	10 минут	1. Нарежьте помидоры и моцареллу кружочками.\n2. Выложите на тарелку, чередуя с листьями базилика.\n3. Полейте оливковым маслом и бальзамическим уксусом.	Caprese Salad	Sliced tomato and fresh mozzarella layered with basil, olive oil and balsamic glaze.	1. Slice the tomatoes and mozzarella into rounds.\n2. Arrange alternating with basil leaves on a plate.\n3. Drizzle with olive oil and balsamic vinegar.	10 minutes
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	Крем-суп из томатов	Томаты, долго тушённые с чесноком и базиликом, с добавлением сливок.	https://images.unsplash.com/photo-1547592166-23ac45744acd?w=1200	4	2026-09-20 20:06:52.094+00	\N	40 минут	1. Обжарьте нарезанный лук и чеснок на оливковом масле до мягкости.\n2. Добавьте томаты и бульон, доведите до кипения и варите.\n3. Измельчите блендером до однородности, вмешайте сливки и базилик.\n4. Посолите по вкусу и подавайте тёплым.	Creamy Tomato Soup	Slow-simmered tomatoes with garlic and basil, finished with a swirl of cream.	1. Sauté diced onion and garlic in olive oil until soft.\n2. Add tomatoes and broth, then simmer.\n3. Blend until smooth, stir in the cream and basil.\n4. Season to taste and serve warm.	40 minutes
91625d88-13da-4b3e-bffe-642468e12642	Куриный суп с лапшой	Согревающая классика: нежная курица, яичная лапша, морковь и сельдерей в наваристом бульоне.	https://images.unsplash.com/photo-1547592166-23ac45744acd?w=1200	4	2026-09-20 20:06:52.118+00	\N	45 минут	1. Обжарьте нарезанные лук, морковь и сельдерей до мягкости.\n2. Добавьте куриную грудку и бульон, варите до готовности курицы.\n3. Выньте курицу, разберите на волокна и верните в кастрюлю вместе с лапшой.\n4. Варите до готовности лапши.	Chicken Noodle Soup	A comforting classic with tender chicken, egg noodles, carrot and celery in a savory broth.	1. Sauté diced onion, carrot and celery until softened.\n2. Add chicken breast and broth, simmer until chicken is cooked.\n3. Remove chicken, shred it, and return to the pot with the noodles.\n4. Simmer until noodles are tender.	45 minutes
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	Чечевичный суп	Сытная красная чечевица, тушённая с морковью, луком, чесноком и зирой.	https://images.unsplash.com/photo-1547592180-85f173990554?w=1200	4	2026-09-20 20:06:52.142+00	\N	40 минут	1. Обжарьте лук, морковь и чеснок на оливковом масле с зирой до появления аромата.\n2. Добавьте чечевицу и бульон, варите до мягкости чечевицы.\n3. Частично измельчите блендером для кремовой, но текстурной консистенции, посолите по вкусу.	Lentil Soup	Hearty red lentils simmered with carrot, onion, garlic and warming cumin.	1. Sauté onion, carrot and garlic in olive oil with cumin until fragrant.\n2. Add lentils and broth, then simmer until lentils are tender.\n3. Blend partially for a creamy-but-textured soup, and season to taste.	40 minutes
f38548d2-d155-4fec-9617-e9ac40e02a07	Грибной суп	Ароматные грибы, тушённые с чесноком и тимьяном в насыщенном сливочном бульоне.	https://images.unsplash.com/photo-1547592180-85f173990554?w=1200	4	2026-09-20 20:06:52.167+00	\N	35 минут	1. Обжарьте нарезанные грибы, лук и чеснок на сливочном масле до золотистого цвета.\n2. Добавьте бульон и варите.\n3. Измельчите блендером до однородности и вмешайте сливки.	Mushroom Soup	Earthy mushrooms simmered with garlic and thyme in a rich, creamy broth.	1. Sauté sliced mushrooms, onion and garlic in butter until golden.\n2. Add broth and simmer.\n3. Blend until smooth, then stir in the cream.	35 minutes
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	Тыквенный суп	Бархатистый суп из запечённой тыквы с кокосовым молоком и мускатным орехом.	https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?w=1200	4	2026-09-20 20:06:52.19+00	\N	45 минут	1. Обжарьте нарезанный лук и чеснок на оливковом масле.\n2. Добавьте тыкву кубиками и бульон, варите до мягкости.\n3. Измельчите блендером до шелковистой консистенции, вмешайте кокосовое молоко и мускатный орех.	Pumpkin Soup	Velvety roasted pumpkin soup with coconut milk and a hint of nutmeg.	1. Sauté diced onion and garlic in olive oil.\n2. Add cubed pumpkin and broth, simmer until tender.\n3. Blend until silky smooth, then stir in coconut milk and nutmeg.	45 minutes
6d1f2df4-0033-4df1-84f8-81766fdab681	Спагетти болоньезе	Насыщенный, долго тушённый рагу из говядины и томатов со спагетти и пармезаном.	https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=1200	4	2026-09-20 20:06:52.218+00	\N	45 минут	1. Обжарьте лук и чеснок на оливковом масле, затем обжарьте говяжий фарш до румяности.\n2. Добавьте томаты и тушите до густого рагу.\n3. Отварите спагетти в подсоленной воде до состояния аль денте.\n4. Смешайте пасту с рагу и посыпьте тёртым пармезаном.	Spaghetti Bolognese	A rich, slow-simmered beef and tomato ragu tossed with spaghetti and parmesan.	1. Sauté onion and garlic in olive oil, then brown the ground beef.\n2. Add tomatoes and simmer into a rich ragu.\n3. Cook the spaghetti in salted boiling water until al dente.\n4. Toss the pasta with the ragu and finish with grated parmesan.	45 minutes
b94a2523-8f7c-4e34-9f3c-97012d894236	Овощи стир-фрай	Яркая смесь хрустящих овощей и тофу в пикантном соусе с чесноком и имбирём.	https://images.unsplash.com/photo-1512058564366-18510be2db19?w=1200	2	2026-09-20 20:06:52.647+00	\N	25 минут	1. Отварите рис согласно инструкции на упаковке.\n2. Обжарьте чеснок, имбирь и овощи на кунжутном масле до хрустящей мягкости.\n3. Заправьте соевым соусом и подавайте с рисом.	Vegetable Stir Fry	A colorful mix of crisp vegetables and tofu tossed in a savory garlic-ginger sauce.	1. Cook the rice according to package instructions.\n2. Stir-fry garlic, ginger and vegetables in sesame oil until crisp-tender.\n3. Toss with soy sauce and serve over rice.	25 minutes
e8c73af2-eee6-46f8-8932-2dfa7335216c	Паста Альфредо с курицей	Феттучине в нежном сливочном соусе с чесноком и пармезаном, с обжаренной курицей.	https://images.unsplash.com/photo-1645112411341-6c4fd023714a?w=1200	4	2026-09-20 20:06:52.246+00	\N	30 минут	1. Отварите пасту в подсоленной воде до состояния аль денте.\n2. Обжарьте курицу до готовности, затем нарежьте.\n3. Растопите масло с чесноком, добавьте сливки и пармезан, доведите до соуса.\n4. Смешайте пасту и курицу с соусом.	Chicken Alfredo Pasta	Fettuccine tossed in a silky garlic-parmesan cream sauce with seared chicken.	1. Cook the pasta in salted boiling water until al dente.\n2. Sear the chicken until cooked through, then slice.\n3. Melt butter with garlic, add cream and parmesan, and simmer into a sauce.\n4. Toss the pasta and chicken through the sauce.	30 minutes
e84c5f38-9e4c-4cc7-8570-949a449019a1	Паста с песто	Яркий соус песто из базилика и кедровых орехов с пастой и черри помидорами.	https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=1200	4	2026-09-20 20:06:52.27+00	\N	22 минут	1. Отварите пасту в подсоленной воде до состояния аль денте.\n2. Измельчите блендером базилик, кедровые орехи, пармезан, чеснок и оливковое масло до однородного песто.\n3. Смешайте пасту с песто и разрезанными пополам черри помидорами.	Pesto Pasta	A vibrant basil-pine nut pesto tossed with pasta and burst cherry tomatoes.	1. Cook the pasta in salted boiling water until al dente.\n2. Blend basil, pine nuts, parmesan, garlic and olive oil into a smooth pesto.\n3. Toss the pasta with pesto and halved cherry tomatoes.	22 minutes
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	Паста с креветками и чесноком	Лингвини с креветками в чесноке, хлопьями чили и свежим лимонным соком.	https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=1200	4	2026-09-20 20:06:52.308+00	\N	25 минут	1. Отварите пасту в подсоленной воде до состояния аль денте.\n2. Обжарьте чеснок и хлопья чили на оливковом масле, добавьте креветки и обжарьте до готовности.\n3. Смешайте пасту с креветками, петрушкой и лимонным соком.	Shrimp Garlic Pasta	Linguine tossed with garlicky shrimp, chili flakes and a bright squeeze of lemon.	1. Cook the pasta in salted boiling water until al dente.\n2. Sauté garlic and chili flakes in olive oil, add shrimp and cook through.\n3. Toss the pasta with the shrimp, parsley and a squeeze of lemon.	25 minutes
32ec3894-ff68-4ebb-994f-a32c00c9c98c	Паста со шпинатом и рикоттой	Паста с тушёным шпинатом, нежной рикоттой и пармезаном.	https://images.unsplash.com/photo-1611270629569-8b357cb88da9?w=1200	4	2026-09-20 20:06:52.335+00	\N	25 минут	1. Отварите пасту в подсоленной воде до состояния аль денте.\n2. Обжарьте чеснок на оливковом масле, добавьте шпинат и потушите до мягкости.\n3. Вмешайте рикотту и немного воды от пасты для консистенции, смешайте с пастой и пармезаном.	Spinach Ricotta Pasta	Pasta tossed with wilted spinach, creamy ricotta and shaved parmesan.	1. Cook the pasta in salted boiling water until al dente.\n2. Sauté garlic in olive oil, wilt in the spinach.\n3. Stir in ricotta and a splash of pasta water to loosen, then toss with pasta and parmesan.	25 minutes
2f36a55a-2dd4-49a5-ba21-07c29e397e46	Жареная курица с рисом	Сочная жареная куриная грудка с брокколи на пару и рисом с лимоном и чесноком.	https://images.unsplash.com/photo-1598515213692-5f252f1c3e0d?w=1200	2	2026-09-20 20:06:52.362+00	\N	35 минут	1. Отварите рис согласно инструкции на упаковке.\n2. Обжарьте приправленную куриную грудку до готовности.\n3. Приготовьте брокколи на пару до яркого зелёного цвета и мягкости.\n4. Разрыхлите рис вилкой, добавив чеснок и лимонный сок, выложите всё на тарелку.	Grilled Chicken with Rice	Juicy grilled chicken breast with steamed broccoli and lemon-garlic rice.	1. Cook the rice according to package instructions.\n2. Grill the seasoned chicken breast until cooked through.\n3. Steam the broccoli until bright green and tender.\n4. Fluff the rice with garlic and lemon juice, and plate everything together.	35 minutes
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	Говядина стир-фрай	Нежная говяжья вырезка, обжаренная с болгарским перцем и брокколи в соево-имбирном соусе.	https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=1200	2	2026-09-20 20:06:52.386+00	\N	27 минут	1. Отварите рис согласно инструкции на упаковке.\n2. Нарежьте говядину тонкими ломтиками и ненадолго замаринуйте в соевом соусе.\n3. Обжарьте говядину на кунжутном масле до румяности, отложите в сторону.\n4. Обжарьте чеснок, имбирь, болгарский перец и брокколи до хрустящей мягкости.\n5. Верните говядину на сковороду, перемешайте и подавайте с рисом.	Beef Stir Fry	Tender beef sirloin stir-fried with bell pepper and broccoli in a savory soy-ginger sauce.	1. Cook the rice according to package instructions.\n2. Slice the beef thinly and marinate briefly in soy sauce.\n3. Stir-fry beef in sesame oil until browned, then set aside.\n4. Stir-fry garlic, ginger, bell pepper and broccoli until crisp-tender.\n5. Return the beef to the pan, toss together and serve over rice.	27 minutes
d57fee08-890c-4b31-9925-b611eb4ee259	Куриное карри	Нежное куриное бедро, тушённое в ароматном кокосовом соусе карри.	https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=1200	4	2026-09-20 20:06:52.415+00	\N	45 минут	1. Отварите рис согласно инструкции на упаковке.\n2. Обжарьте лук, чеснок и имбирь до аромата, вмешайте порошок карри.\n3. Добавьте кусочки куриного бедра и слегка обжарьте.\n4. Влейте кокосовое молоко и томаты, тушите до мягкости курицы.\n5. Подавайте с рисом.	Chicken Curry	Tender chicken thigh simmered in a fragrant coconut curry sauce.	1. Cook the rice according to package instructions.\n2. Sauté onion, garlic and ginger until fragrant, then stir in curry powder.\n3. Add chicken thigh pieces and brown lightly.\n4. Pour in coconut milk and tomatoes, then simmer until chicken is tender.\n5. Serve over rice.	45 minutes
0c161c39-c237-45f1-a8e6-9646fb0fbb41	Фаршированный болгарский перец	Болгарский перец, фаршированный приправленным говяжьим фаршем, рисом и томатом, запечённый до мягкости.	https://images.unsplash.com/photo-1600335895229-6e75511892c8?w=1200	4	2026-09-20 20:06:52.445+00	\N	50 минут	1. Отварите рис согласно инструкции на упаковке.\n2. Срежьте верхушки перцев и удалите семена.\n3. Обжарьте говяжий фарш с луком, вмешайте рис и половину томатов.\n4. Наполните перцы начинкой, сверху выложите оставшиеся томаты и чеддер.\n5. Запекайте при 190°C до мягкости перцев.	Stuffed Bell Peppers	Bell peppers filled with seasoned ground beef, rice and tomato, baked until tender.	1. Cook the rice according to package instructions.\n2. Slice the tops off the bell peppers and remove seeds.\n3. Brown the ground beef with onion, then stir in rice and half the tomatoes.\n4. Fill the peppers with the mixture, top with remaining tomato and cheddar.\n5. Bake at 190°C (375°F) until peppers are tender.	50 minutes
16b42f5e-ef62-41ce-8173-689364aab67b	Индюшиные фрикадельки	Нежирные индюшиные фрикадельки, тушённые в томатном соусе, с пармезаном и петрушкой.	https://images.unsplash.com/photo-1529042410759-befb1204b468?w=1200	4	2026-09-20 20:06:52.474+00	\N	40 минут	1. Смешайте индюшиный фарш, панировочные сухари, яйцо, пармезан и измельчённый чеснок, сформируйте фрикадельки.\n2. Обжарьте фрикадельки со всех сторон.\n3. Добавьте томатный соус и тушите до готовности фрикаделек.\n4. Посыпьте рубленой петрушкой.	Turkey Meatballs	Lean turkey meatballs simmered in tomato sauce, finished with parmesan and parsley.	1. Combine turkey, breadcrumbs, egg, parmesan and minced garlic; form into meatballs.\n2. Sear the meatballs on all sides.\n3. Add tomato sauce and simmer until meatballs are cooked through.\n4. Finish with chopped parsley.	40 minutes
815b25ac-172d-4ace-93f8-bbfba78d3cbb	Жареный лосось	Просто обжаренное филе лосося с чесноком, лимоном и запечённой спаржей.	https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=1200	2	2026-09-20 20:06:52.502+00	\N	25 минут	1. Приправьте лосось солью, перцем и измельчённым чесноком.\n2. Обжарьте лосось кожей вниз до готовности.\n3. Запеките спаржу с оливковым маслом до мягкости.\n4. Подавайте со свежевыжатым лимонным соком.	Grilled Salmon	Simply grilled salmon fillet with garlic, lemon and roasted asparagus.	1. Season the salmon with salt, pepper and minced garlic.\n2. Grill salmon skin-side down until just cooked through.\n3. Roast the asparagus with olive oil until tender.\n4. Serve with a squeeze of fresh lemon.	25 minutes
f14e5642-72b4-45ac-8f19-12aa135d3681	Запечённая треска	Нежное филе трески, запечённое под хрустящей корочкой из сухарей с чесноком и петрушкой.	https://images.unsplash.com/photo-1580476262798-bddd9f4b7369?w=1200	2	2026-09-20 20:06:52.531+00	\N	28 минут	1. Смешайте панировочные сухари с оливковым маслом, измельчённым чесноком и рубленой петрушкой.\n2. Обсушите треску и прижмите сверху смесь из сухарей.\n3. Запекайте при 200°C, пока рыба легко не будет разделяться на волокна.\n4. Подавайте с долькой лимона.	Baked Cod	Flaky cod fillet baked under a crisp garlic-parsley breadcrumb crust.	1. Mix breadcrumbs with olive oil, minced garlic and chopped parsley.\n2. Pat the cod dry and press the breadcrumb mixture on top.\n3. Bake at 200°C (400°F) until fish flakes easily.\n4. Serve with a wedge of lemon.	28 minutes
a934d358-7d10-492f-a3de-e2d5073aa03b	Стейк тунца	Обжаренный стейк тунца в кунжутной корочке с соево-кунжутной глазурью.	https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=1200	2	2026-09-20 20:06:52.559+00	\N	16 минут	1. Обваляйте стейк тунца с обеих сторон в кунжутных семенах.\n2. Обжарьте на кунжутном масле до слабой прожарки внутри.\n3. Нарежьте тонкими ломтиками, полейте соевым соусом и посыпьте зелёным луком.	Tuna Steak	Seared sesame-crusted tuna steak with a soy-sesame glaze.	1. Press sesame seeds onto both sides of the tuna steak.\n2. Sear in sesame oil for a rare-medium center.\n3. Slice thinly, drizzle with soy sauce and top with spring onion.	16 minutes
807c0131-350c-4dcb-b5e7-572c3a323dd1	Креветки в чесночном масле	Сочные креветки, обжаренные в чесночном масле с лимоном, петрушкой и остринкой чили.	https://images.unsplash.com/photo-1625943913492-5b7f2c8b0e6a?w=1200	2	2026-09-20 20:06:52.586+00	\N	18 минут	1. Растопите масло на сковороде, обжарьте чеснок и хлопья чили до аромата.\n2. Добавьте креветки и готовьте, пока не порозовеют.\n3. Сбрызните лимонным соком и посыпьте рубленой петрушкой.	Garlic Butter Shrimp	Juicy shrimp sautéed in garlic butter with lemon, parsley and a kick of chili.	1. Melt butter in a pan and sauté garlic and chili flakes until fragrant.\n2. Add shrimp and cook until pink and opaque.\n3. Finish with a squeeze of lemon and chopped parsley.	18 minutes
9f5e8033-7b4e-40f8-b110-7d97907cc12f	Рыбные тако	Нежная запечённая треска в тёплых кукурузных тортильях с хрустящим капустным салатом и соусом на основе лайма.	https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=1200	3	2026-09-20 20:06:52.616+00	\N	30 минут	1. Приправьте и запеките треску до готовности.\n2. Смешайте нашинкованную капусту с соком лайма для быстрого салата.\n3. Разогрейте тортильи и выложите в них рыбу кусочками.\n4. Добавьте капустный салат, ломтики авокадо, сметану и кинзу.	Fish Tacos	Flaky baked cod in warm corn tortillas with crunchy cabbage slaw and lime crema.	1. Season and bake the cod until flaky.\n2. Toss shredded cabbage with lime juice for a quick slaw.\n3. Warm the tortillas, then flake the fish into them.\n4. Top with slaw, avocado slices, sour cream and cilantro.	30 minutes
92649054-941a-4101-98c7-cf630b94c3c8	Фаршированные грибы портобелло	Шляпки портобелло, фаршированные шпинатом с чесноком, фетой и сухарями, запечённые до золотистой корочки.	https://images.unsplash.com/photo-1541591425126-4e6cc0a4d40a?w=1200	2	2026-09-20 20:06:52.676+00	\N	35 минут	1. Удалите ножки грибов и смажьте шляпки оливковым маслом.\n2. Обжарьте чеснок со шпинатом до мягкости, смешайте с фетой и сухарями.\n3. Наполните шляпки грибов начинкой.\n4. Запекайте при 200°C до золотистого цвета.	Stuffed Portobello Mushrooms	Portobello caps filled with garlicky spinach, feta and breadcrumbs, baked until golden.	1. Remove mushroom stems and brush caps with olive oil.\n2. Sauté garlic and spinach until wilted, then mix with feta and breadcrumbs.\n3. Fill the mushroom caps with the mixture.\n4. Bake at 200°C (400°F) until golden.	35 minutes
026effe9-98b1-4483-bd8a-31c4c6a280af	Клаб-сэндвич с индейкой	Классический трёхслойный сэндвич с индюшиной грудкой, хрустящим беконом, салатом и помидором.	https://images.unsplash.com/photo-1481070555726-e2fe8357725c?w=1200	1	2026-09-20 20:06:52.702+00	\N	18 минут	1. Обжарьте бекон до хруста.\n2. Поджарьте ломтики хлеба.\n3. Выложите между хлебом индейку, бекон, салат и помидор с майонезом.	Turkey Club Sandwich	A triple-decker classic with turkey breast, crispy bacon, lettuce and tomato.	1. Cook the bacon until crisp.\n2. Toast the bread slices.\n3. Layer turkey, bacon, lettuce and tomato between the bread with mayonnaise.	18 minutes
58096b55-e187-4053-a651-86cf973c5901	Панини «Капрезе»	Панини на гриле со свежей моцареллой, помидором и базиликом.	https://images.unsplash.com/photo-1528736235302-52922df5c122?w=1200	1	2026-09-20 20:06:52.726+00	\N	14 минут	1. Выложите между хлебом моцареллу, ломтики помидора и базилик.\n2. Смажьте хлеб снаружи оливковым маслом.\n3. Обжарьте в панини-прессе до золотистого цвета и расплавления сыра.	Caprese Panini	A grilled panini with fresh mozzarella, tomato and basil.	1. Layer mozzarella, tomato slices and basil between the bread.\n2. Brush the outside with olive oil.\n3. Grill in a panini press until golden and the cheese melts.	14 minutes
816b5378-aa22-4a80-a8d9-08374ab87933	Брускетта	Поджаренный багет со свежей смесью из помидоров, базилика и чеснока.	https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?w=1200	4	2026-09-20 20:06:52.751+00	\N	15 минут	1. Поджарьте ломтики багета до хруста.\n2. Нарежьте помидоры кубиками и смешайте с рубленым базиликом, чесноком и оливковым маслом.\n3. Натрите каждый тост чесноком и выложите сверху томатную смесь.	Bruschetta	Toasted baguette topped with a fresh tomato, basil and garlic mixture.	1. Toast the baguette slices until crisp.\n2. Dice the tomatoes and mix with chopped basil, minced garlic and olive oil.\n3. Rub each toast with garlic and spoon the tomato mixture on top.	15 minutes
68cd36a5-aef0-4385-9481-5fe930d7ea0c	Фаршированные грибы	Миниатюрные грибы с нежной начинкой из чеснока и пармезана.	https://images.unsplash.com/photo-1541529086526-db283c563270?w=1200	4	2026-09-20 20:06:52.776+00	\N	35 минут	1. Удалите ножки грибов и мелко нарежьте.\n2. Смешайте нарезанные ножки со сливочным сыром, чесноком, сухарями и пармезаном.\n3. Наполните шляпки грибов начинкой.\n4. Запекайте при 190°C до золотистого цвета.	Stuffed Mushrooms	Bite-sized mushrooms filled with a creamy garlic-parmesan filling.	1. Remove mushroom stems and finely chop them.\n2. Mix chopped stems with cream cheese, garlic, breadcrumbs and parmesan.\n3. Fill the mushroom caps with the mixture.\n4. Bake at 190°C (375°F) until golden.	35 minutes
686e8a44-b024-47fb-8234-53993287656e	Парфе из греческого йогурта с ягодами	Слои греческого йогурта, ягод, мёда и гранолы в стакане.	https://images.unsplash.com/photo-1488477181946-6428a0291777?w=1200	1	2026-09-20 20:06:52.798+00	\N	5 минут	1. Выложите слоями йогурт, ягоды и гранолу в стакан, повторив дважды.\n2. Полейте мёдом сверху.	Greek Yogurt Berry Parfait	Layers of Greek yogurt, mixed berries, honey and granola in a glass.	1. Layer yogurt, berries and granola in a glass, repeating twice.\n2. Finish with a drizzle of honey on top.	5 minutes
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	Энергетические шарики с тёмным шоколадом	Шарики без выпечки из овсянки, арахисовой пасты, тёмного шоколада и семян чиа.	https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=1200	10	2026-09-20 20:06:52.819+00	\N	15 минут	1. Нарежьте тёмный шоколад мелкими кусочками.\n2. Смешайте овсянку, арахисовую пасту, мёд и семена чиа до однородности, вмешайте шоколад.\n3. Скатайте в шарики и охладите до застывания.	Dark Chocolate Energy Bites	No-bake bites of oats, peanut butter, dark chocolate and chia seeds.	1. Chop the dark chocolate into small chunks.\n2. Mix oats, peanut butter, honey and chia seeds until well combined, then fold in chocolate.\n3. Roll into balls and chill until firm.	15 minutes
c14d8f43-9f79-4849-9b63-8799a2185fc3	Цельнозерновой банановый хлеб	Влажный, слегка сладкий банановый хлеб с грецкими орехами.	https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200	10	2026-09-20 20:06:52.843+00	\N	1 ч 10 мин	1. Разомните бананы и смешайте с растопленным маслом, мёдом и яйцами.\n2. Вмешайте муку и разрыхлитель до однородности, добавьте грецкие орехи.\n3. Вылейте в смазанную маслом форму для хлеба.\n4. Выпекайте при 175°C, пока зубочистка не будет выходить сухой.	Whole Wheat Banana Bread	A moist, lightly sweet banana bread studded with walnuts.	1. Mash the bananas and mix with melted butter, honey and eggs.\n2. Fold in flour and baking powder until just combined, then stir in walnuts.\n3. Pour into a greased loaf pan.\n4. Bake at 175°C (350°F) until a toothpick comes out clean.	1h 10m
7409b248-a723-48d5-b993-272de6b18346	Черничные маффины	Маффины в стиле пекарни с сочной черникой.	https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=1200	12	2026-09-20 20:06:52.872+00	\N	37 минут	1. Взбейте растопленное масло, мёд, яйца и молоко.\n2. Вмешайте муку и разрыхлитель, аккуратно добавьте чернику.\n3. Разлейте тесто по формочкам для маффинов.\n4. Выпекайте при 190°C до золотистого цвета и упругости.	Blueberry Muffins	Bakery-style muffins bursting with juicy blueberries.	1. Whisk melted butter, honey, eggs and milk together.\n2. Fold in flour and baking powder, then gently fold in blueberries.\n3. Divide batter among muffin cups.\n4. Bake at 190°C (375°F) until golden and springy.	37 minutes
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	Ягодный протеиновый смузи	Густой, богатый белком смузи с ягодами, бананом и греческим йогуртом.	https://images.unsplash.com/photo-1502741338009-cac2772e18bc?w=1200	1	2026-09-20 20:06:52.902+00	\N	5 минут	1. Добавьте все ингредиенты в блендер.\n2. Взбейте до однородной кремовой консистенции.\n3. Перелейте в стакан и подавайте охлаждённым.	Berry Protein Smoothie	A thick, protein-packed smoothie with mixed berries, banana and Greek yogurt.	1. Add all ingredients to a blender.\n2. Blend until smooth and creamy.\n3. Pour into a glass and serve chilled.	5 minutes
58b9fd50-9ae8-4f29-b61c-344218bc98f5	Зелёный смузи-детокс	Освежающий смузи из шпината, банана, яблока и семян чиа.	https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=1200	1	2026-09-20 20:06:52.927+00	\N	5 минут	1. Добавьте все ингредиенты в блендер.\n2. Взбейте до однородности.\n3. Перелейте в стакан и подавайте сразу.	Green Detox Smoothie	A refreshing blend of spinach, banana, apple and chia seeds.	1. Add all ingredients to a blender.\n2. Blend until smooth.\n3. Pour into a glass and enjoy immediately.	5 minutes
bed7dd31-1676-4af4-9117-9efd1f0607d7	Холодный матча-латте	Взбитая церемониальная матча со льдом, холодным молоком и каплей мёда.	https://images.unsplash.com/photo-1515823064-d6e0c04616a7?w=1200	1	2026-09-20 20:06:52.953+00	\N	5 минут	1. Взбейте порошок матча с небольшим количеством горячей воды до пены.\n2. Наполните стакан льдом, влейте молоко, сверху добавьте матчу и мёд.	Iced Matcha Latte	Whisked ceremonial matcha over ice with cold milk and a touch of honey.	1. Whisk matcha powder with a splash of hot water until frothy.\n2. Fill a glass with ice, pour in milk, then top with the matcha and honey.	5 minutes
1503796f-f108-4270-9fbe-7b1516c0a18d	Манговый ласси	Кремовый охлаждённый напиток на основе йогурта в индийском стиле со сладким спелым манго.	https://images.unsplash.com/photo-1546173159-315724a31696?w=1200	1	2026-09-20 20:06:52.974+00	\N	5 минут	1. Добавьте все ингредиенты в блендер.\n2. Взбейте до однородной пенистой консистенции.\n3. Подавайте охлаждённым со льдом.	Mango Lassi	A creamy, chilled Indian-style yogurt drink blended with sweet ripe mango.	1. Add all ingredients to a blender.\n2. Blend until smooth and frothy.\n3. Serve chilled over ice.	5 minutes
\.


--
-- Data for Name: recipe_ingredient; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipe_ingredient (recipe_id, ingredient_id, quantity, unit) FROM stdin;
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	64493b76-b118-4fae-b92e-be8f70bc2b4c	2.000	slice
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	b6f720c8-2e7b-4f8e-adb4-b57022d99a0f	1.000	piece
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	1d8538a5-2082-4d35-99bf-843ed8c18e3c	1.000	piece
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	44e5597d-692b-44c2-8549-670086c5237b	1.000	tsp
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	f885e5af-eee5-44b5-9f91-58ed0b8fec09	0.500	tsp
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tsp
90627aea-d9f9-46ff-bd2a-21112d6feaad	8e80d460-222c-4969-83c7-7d3bd8ef2979	200.000	g
90627aea-d9f9-46ff-bd2a-21112d6feaad	a7ef29ff-a2c2-4861-98e4-64aa261fb8c8	1.000	cup
90627aea-d9f9-46ff-bd2a-21112d6feaad	75f64318-0e35-4497-922b-cef681139d83	1.000	tbsp
90627aea-d9f9-46ff-bd2a-21112d6feaad	be39aa1e-2b5d-4da0-bc4e-f05b09216616	0.250	cup
d67e7969-8efe-4e9a-82be-9ff4d85fc571	b4533f1f-9c8e-47fe-9341-1f3e9e370b83	0.500	cup
d67e7969-8efe-4e9a-82be-9ff4d85fc571	8ab706f2-1c77-478a-9e31-e1d04f27224c	200.000	ml
d67e7969-8efe-4e9a-82be-9ff4d85fc571	a75ae202-b7d5-4882-be33-0635029521c2	1.000	piece
d67e7969-8efe-4e9a-82be-9ff4d85fc571	bad18d5c-4b6d-451f-8182-0ae50d044c1d	0.500	tsp
d67e7969-8efe-4e9a-82be-9ff4d85fc571	75f64318-0e35-4497-922b-cef681139d83	1.000	tsp
d67e7969-8efe-4e9a-82be-9ff4d85fc571	457f1060-ef40-4a5b-a2df-85f2e1d7a435	15.000	g
71551f3d-b1e1-45f4-ab74-266b7479c55d	1d8538a5-2082-4d35-99bf-843ed8c18e3c	3.000	piece
71551f3d-b1e1-45f4-ab74-266b7479c55d	d91abeb4-8b86-4567-85e1-b3c576bf68bc	1.000	cup
71551f3d-b1e1-45f4-ab74-266b7479c55d	f6576856-fb2a-4789-a7a8-0daef7f9949f	30.000	g
71551f3d-b1e1-45f4-ab74-266b7479c55d	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tsp
fd48d17b-86df-4000-9799-6933b6873f81	bb7cae1c-9ed6-43cd-9b3f-3e5b8c148f88	200.000	g
fd48d17b-86df-4000-9799-6933b6873f81	1d8538a5-2082-4d35-99bf-843ed8c18e3c	2.000	piece
fd48d17b-86df-4000-9799-6933b6873f81	b4533f1f-9c8e-47fe-9341-1f3e9e370b83	0.500	cup
fd48d17b-86df-4000-9799-6933b6873f81	a75ae202-b7d5-4882-be33-0635029521c2	1.000	piece
fd48d17b-86df-4000-9799-6933b6873f81	9142f0e2-55d3-4ee9-8cf9-edfb498c9313	0.500	tsp
fd48d17b-86df-4000-9799-6933b6873f81	b75a7fb9-17cd-4bd3-8463-368f0312e201	1.000	tbsp
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	e6887371-382e-4c0c-b841-1a40e6c9f897	1.000	piece
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	e489a9b7-4df7-4d1c-b736-6fee915e9ae7	2.000	tbsp
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	c77109ba-d9d5-487e-be10-9134ca9ff4b6	80.000	g
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	68c6aa8c-825f-4f27-8cec-5a2726e2d46e	20.000	g
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	6e8198f8-5655-44a3-8fb6-c08c8bdfeb37	1.000	tsp
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	6b910dcf-9133-4810-9078-33961d0c63e2	2.000	g
1b55a005-6344-4714-9aa7-97837cca2086	ebce98c5-24da-49a1-97d3-553bf577ab4e	2.000	piece
1b55a005-6344-4714-9aa7-97837cca2086	a9c2aca7-7390-4af3-a5f4-c19c2f822fb1	4.000	slice
1b55a005-6344-4714-9aa7-97837cca2086	1d8538a5-2082-4d35-99bf-843ed8c18e3c	4.000	piece
1b55a005-6344-4714-9aa7-97837cca2086	b75a7fb9-17cd-4bd3-8463-368f0312e201	3.000	tbsp
1b55a005-6344-4714-9aa7-97837cca2086	44e5597d-692b-44c2-8549-670086c5237b	1.000	tbsp
1b55a005-6344-4714-9aa7-97837cca2086	b8a3e0fb-6d4e-4139-8751-8e1773b0d2bc	2.000	g
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	310f681b-20dc-46f5-9fe0-8876bf5cdb37	1.000	piece
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	dbf4a44b-1ac1-4286-9504-16c426b5e7f5	120.000	g
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	66eb1a53-79a4-4a4c-8bb8-25fe823055c6	60.000	g
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	e0c7a66e-0716-43c1-8027-b1e721108d5b	15.000	g
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	583d36ed-70c5-42d4-a2b3-87bc4e4b8a8e	2.000	tbsp
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tsp
74e74a2f-3579-4619-a911-fd5af69f6fd7	aa53b8ba-121c-4cde-af29-a3a0be157270	2.000	slice
74e74a2f-3579-4619-a911-fd5af69f6fd7	dbf4a44b-1ac1-4286-9504-16c426b5e7f5	120.000	g
74e74a2f-3579-4619-a911-fd5af69f6fd7	b6f720c8-2e7b-4f8e-adb4-b57022d99a0f	0.500	piece
74e74a2f-3579-4619-a911-fd5af69f6fd7	5086c70a-eb85-4e61-aa8d-e81ce1167a03	0.500	piece
74e74a2f-3579-4619-a911-fd5af69f6fd7	66eb1a53-79a4-4a4c-8bb8-25fe823055c6	20.000	g
74e74a2f-3579-4619-a911-fd5af69f6fd7	f3244cab-948a-43e9-9d33-514996ddee16	1.000	tbsp
8f48e7b7-611c-428b-899a-a1ca55f41779	a9a1bad9-4eca-43e7-b6d7-ee335e2702c8	150.000	g
8f48e7b7-611c-428b-899a-a1ca55f41779	b75a7fb9-17cd-4bd3-8463-368f0312e201	90.000	g
8f48e7b7-611c-428b-899a-a1ca55f41779	1d8538a5-2082-4d35-99bf-843ed8c18e3c	5.000	piece
8f48e7b7-611c-428b-899a-a1ca55f41779	8ab706f2-1c77-478a-9e31-e1d04f27224c	150.000	ml
8f48e7b7-611c-428b-899a-a1ca55f41779	d91abeb4-8b86-4567-85e1-b3c576bf68bc	2.000	cup
8f48e7b7-611c-428b-899a-a1ca55f41779	82090119-5b09-4c87-8af4-b0c63ab75a3a	1.000	piece
8f48e7b7-611c-428b-899a-a1ca55f41779	645bcd1c-a04a-4498-9541-21a9ea7d3447	80.000	g
8f48e7b7-611c-428b-899a-a1ca55f41779	25864bc1-ebe0-4b33-92c4-8e81f479a18d	0.500	piece
a8b44445-3f32-4ab8-88e0-34c72fc1671b	c88015b8-3085-4148-be53-d4310f21b23d	1.000	piece
a8b44445-3f32-4ab8-88e0-34c72fc1671b	5086c70a-eb85-4e61-aa8d-e81ce1167a03	2.000	piece
a8b44445-3f32-4ab8-88e0-34c72fc1671b	68c6aa8c-825f-4f27-8cec-5a2726e2d46e	0.250	piece
a8b44445-3f32-4ab8-88e0-34c72fc1671b	f6576856-fb2a-4789-a7a8-0daef7f9949f	100.000	g
a8b44445-3f32-4ab8-88e0-34c72fc1671b	26bc159e-d6a8-49ef-abf9-9e3b4d8b87a5	50.000	g
a8b44445-3f32-4ab8-88e0-34c72fc1671b	da0566f8-8a43-4429-b0db-a3a94942a9d3	2.000	tbsp
5f660db5-8f5d-4401-a53c-563ff59dc677	66eb1a53-79a4-4a4c-8bb8-25fe823055c6	200.000	g
5f660db5-8f5d-4401-a53c-563ff59dc677	e0c7a66e-0716-43c1-8027-b1e721108d5b	30.000	g
5f660db5-8f5d-4401-a53c-563ff59dc677	9926a47f-28d3-46bc-90bd-b22c64193ab3	40.000	g
5f660db5-8f5d-4401-a53c-563ff59dc677	583d36ed-70c5-42d4-a2b3-87bc4e4b8a8e	3.000	tbsp
5f660db5-8f5d-4401-a53c-563ff59dc677	dbf4a44b-1ac1-4286-9504-16c426b5e7f5	150.000	g
5f660db5-8f5d-4401-a53c-563ff59dc677	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tsp
6cf92b55-c01f-4e77-a088-81d8bab48af8	53cc9824-7c3b-4016-8ba2-74dee527ccc8	0.500	cup
6cf92b55-c01f-4e77-a088-81d8bab48af8	c88015b8-3085-4148-be53-d4310f21b23d	1.000	piece
6cf92b55-c01f-4e77-a088-81d8bab48af8	4b1367e5-0a83-488b-a8d3-8ed4aa7073ea	150.000	g
6cf92b55-c01f-4e77-a088-81d8bab48af8	6084fb0c-f8df-486d-8bbd-4166cdeaaf22	150.000	g
6cf92b55-c01f-4e77-a088-81d8bab48af8	f6576856-fb2a-4789-a7a8-0daef7f9949f	60.000	g
6cf92b55-c01f-4e77-a088-81d8bab48af8	da0566f8-8a43-4429-b0db-a3a94942a9d3	2.000	tbsp
6cf92b55-c01f-4e77-a088-81d8bab48af8	44e5597d-692b-44c2-8549-670086c5237b	1.000	tbsp
76af319d-ef28-454e-8e8b-f1d8305bafc4	7049f9f9-6892-403c-9915-76c67abd77b6	150.000	g
76af319d-ef28-454e-8e8b-f1d8305bafc4	f3244cab-948a-43e9-9d33-514996ddee16	1.000	tbsp
76af319d-ef28-454e-8e8b-f1d8305bafc4	d18c6c8f-8df0-4d7d-b248-8a6099210cdc	30.000	g
76af319d-ef28-454e-8e8b-f1d8305bafc4	68c6aa8c-825f-4f27-8cec-5a2726e2d46e	20.000	g
76af319d-ef28-454e-8e8b-f1d8305bafc4	44e5597d-692b-44c2-8549-670086c5237b	1.000	tsp
76af319d-ef28-454e-8e8b-f1d8305bafc4	7d807b7e-f17a-427e-bb75-6200cb919578	1.000	cup
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	5086c70a-eb85-4e61-aa8d-e81ce1167a03	3.000	piece
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	82a7642e-d453-4360-ae0c-de1328d37580	150.000	g
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	43cbf2d3-7165-438e-9d6a-9df5afc83ec4	10.000	g
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	da0566f8-8a43-4429-b0db-a3a94942a9d3	2.000	tbsp
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	8465a410-b52c-4577-bbd9-d4080183de05	1.000	tbsp
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	0b7b1ddb-9929-4352-9924-0ca61a7a3b59	800.000	g
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	25864bc1-ebe0-4b33-92c4-8e81f479a18d	1.000	piece
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	7906ec51-1bcd-43ae-9e0c-d0f9c01f73c1	400.000	ml
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	b53e5343-7e07-4574-8d72-43cdf0187014	100.000	ml
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tbsp
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	43cbf2d3-7165-438e-9d6a-9df5afc83ec4	10.000	g
91625d88-13da-4b3e-bffe-642468e12642	dbf4a44b-1ac1-4286-9504-16c426b5e7f5	300.000	g
91625d88-13da-4b3e-bffe-642468e12642	9a77127b-1ca1-415a-a7da-e55c282d1ed5	150.000	g
91625d88-13da-4b3e-bffe-642468e12642	12e0c381-f45a-4d26-866f-47012609b45e	2.000	piece
91625d88-13da-4b3e-bffe-642468e12642	d18c6c8f-8df0-4d7d-b248-8a6099210cdc	2.000	piece
91625d88-13da-4b3e-bffe-642468e12642	25864bc1-ebe0-4b33-92c4-8e81f479a18d	1.000	piece
91625d88-13da-4b3e-bffe-642468e12642	90523ff2-a007-4c89-b75d-47645a6285ea	1200.000	ml
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	903b3ad7-3dfd-4549-bfc8-f891ab7f7a93	250.000	g
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	12e0c381-f45a-4d26-866f-47012609b45e	2.000	piece
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	25864bc1-ebe0-4b33-92c4-8e81f479a18d	1.000	piece
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	7906ec51-1bcd-43ae-9e0c-d0f9c01f73c1	1000.000	ml
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	b6c6ed4e-8ab6-4c1c-86a0-d1ca720dcaae	1.000	tsp
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tbsp
f38548d2-d155-4fec-9617-e9ac40e02a07	a3bdab62-9e64-4377-8761-f8bcd0cb91d2	500.000	g
f38548d2-d155-4fec-9617-e9ac40e02a07	25864bc1-ebe0-4b33-92c4-8e81f479a18d	1.000	piece
f38548d2-d155-4fec-9617-e9ac40e02a07	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
f38548d2-d155-4fec-9617-e9ac40e02a07	7906ec51-1bcd-43ae-9e0c-d0f9c01f73c1	600.000	ml
f38548d2-d155-4fec-9617-e9ac40e02a07	b53e5343-7e07-4574-8d72-43cdf0187014	100.000	ml
f38548d2-d155-4fec-9617-e9ac40e02a07	b75a7fb9-17cd-4bd3-8463-368f0312e201	2.000	tbsp
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	7a3fa257-87ed-4a89-9c55-b658a1e0acbf	800.000	g
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	25864bc1-ebe0-4b33-92c4-8e81f479a18d	1.000	piece
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	7906ec51-1bcd-43ae-9e0c-d0f9c01f73c1	500.000	ml
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	5f556406-9f30-40a1-bdd9-214ebc44ddca	200.000	ml
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	0c0cee98-5262-43c9-b3bb-590c8a0df4e3	0.250	tsp
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tbsp
6d1f2df4-0033-4df1-84f8-81766fdab681	50f81ce7-3738-474e-b2aa-7abc41f3e299	320.000	g
6d1f2df4-0033-4df1-84f8-81766fdab681	c5be005b-8c20-45f7-8293-053ba6f5f95d	400.000	g
6d1f2df4-0033-4df1-84f8-81766fdab681	0b7b1ddb-9929-4352-9924-0ca61a7a3b59	400.000	g
6d1f2df4-0033-4df1-84f8-81766fdab681	25864bc1-ebe0-4b33-92c4-8e81f479a18d	1.000	piece
6d1f2df4-0033-4df1-84f8-81766fdab681	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
6d1f2df4-0033-4df1-84f8-81766fdab681	e0c7a66e-0716-43c1-8027-b1e721108d5b	40.000	g
6d1f2df4-0033-4df1-84f8-81766fdab681	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tbsp
e8c73af2-eee6-46f8-8932-2dfa7335216c	50f81ce7-3738-474e-b2aa-7abc41f3e299	320.000	g
e8c73af2-eee6-46f8-8932-2dfa7335216c	dbf4a44b-1ac1-4286-9504-16c426b5e7f5	300.000	g
e8c73af2-eee6-46f8-8932-2dfa7335216c	b53e5343-7e07-4574-8d72-43cdf0187014	250.000	ml
e8c73af2-eee6-46f8-8932-2dfa7335216c	e0c7a66e-0716-43c1-8027-b1e721108d5b	60.000	g
e8c73af2-eee6-46f8-8932-2dfa7335216c	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
e8c73af2-eee6-46f8-8932-2dfa7335216c	b75a7fb9-17cd-4bd3-8463-368f0312e201	2.000	tbsp
e84c5f38-9e4c-4cc7-8570-949a449019a1	50f81ce7-3738-474e-b2aa-7abc41f3e299	320.000	g
e84c5f38-9e4c-4cc7-8570-949a449019a1	43cbf2d3-7165-438e-9d6a-9df5afc83ec4	40.000	g
e84c5f38-9e4c-4cc7-8570-949a449019a1	ae3e9146-ec42-4d2b-96da-07245ad8b468	30.000	g
e84c5f38-9e4c-4cc7-8570-949a449019a1	e0c7a66e-0716-43c1-8027-b1e721108d5b	40.000	g
e84c5f38-9e4c-4cc7-8570-949a449019a1	95ff2fa0-ff52-4961-836a-6984ba7add98	1.000	clove
e84c5f38-9e4c-4cc7-8570-949a449019a1	da0566f8-8a43-4429-b0db-a3a94942a9d3	4.000	tbsp
e84c5f38-9e4c-4cc7-8570-949a449019a1	4b1367e5-0a83-488b-a8d3-8ed4aa7073ea	150.000	g
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	50f81ce7-3738-474e-b2aa-7abc41f3e299	320.000	g
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	d2ae29d7-17a4-40db-89e8-b20c8f698488	400.000	g
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	95ff2fa0-ff52-4961-836a-6984ba7add98	4.000	clove
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	da0566f8-8a43-4429-b0db-a3a94942a9d3	3.000	tbsp
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	f885e5af-eee5-44b5-9f91-58ed0b8fec09	0.500	tsp
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	73b9bf7c-b87b-4892-a32c-089c2e103d00	10.000	g
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	8f897f2e-ef63-4dbd-9baf-284dddde8a96	1.000	piece
32ec3894-ff68-4ebb-994f-a32c00c9c98c	50f81ce7-3738-474e-b2aa-7abc41f3e299	320.000	g
32ec3894-ff68-4ebb-994f-a32c00c9c98c	6d89dc43-e48b-4005-bbfe-363cb552d0f5	250.000	g
32ec3894-ff68-4ebb-994f-a32c00c9c98c	d91abeb4-8b86-4567-85e1-b3c576bf68bc	3.000	cup
32ec3894-ff68-4ebb-994f-a32c00c9c98c	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
32ec3894-ff68-4ebb-994f-a32c00c9c98c	da0566f8-8a43-4429-b0db-a3a94942a9d3	2.000	tbsp
32ec3894-ff68-4ebb-994f-a32c00c9c98c	e0c7a66e-0716-43c1-8027-b1e721108d5b	30.000	g
2f36a55a-2dd4-49a5-ba21-07c29e397e46	dbf4a44b-1ac1-4286-9504-16c426b5e7f5	300.000	g
2f36a55a-2dd4-49a5-ba21-07c29e397e46	0dafbe10-2d43-4b04-ae62-43c02a6617ec	0.500	cup
2f36a55a-2dd4-49a5-ba21-07c29e397e46	2c43a12f-f532-4df7-b55b-6c312d689340	200.000	g
2f36a55a-2dd4-49a5-ba21-07c29e397e46	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tbsp
2f36a55a-2dd4-49a5-ba21-07c29e397e46	95ff2fa0-ff52-4961-836a-6984ba7add98	1.000	clove
2f36a55a-2dd4-49a5-ba21-07c29e397e46	8f897f2e-ef63-4dbd-9baf-284dddde8a96	0.500	piece
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	ae064946-d37b-46c0-b521-21d1f09c37b7	300.000	g
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	82090119-5b09-4c87-8af4-b0c63ab75a3a	1.000	piece
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	2c43a12f-f532-4df7-b55b-6c312d689340	150.000	g
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	45ec108e-6d34-4295-a61f-c2aea959e8ac	2.000	tbsp
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	de9ff794-b346-47ca-9383-df0bfba09478	10.000	g
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	44d967f0-d877-42b4-ab3c-10c46941b746	1.000	tsp
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	0dafbe10-2d43-4b04-ae62-43c02a6617ec	0.500	cup
d57fee08-890c-4b31-9925-b611eb4ee259	2af5b797-0881-4733-accb-506cf8ec9c78	500.000	g
d57fee08-890c-4b31-9925-b611eb4ee259	5f556406-9f30-40a1-bdd9-214ebc44ddca	400.000	ml
d57fee08-890c-4b31-9925-b611eb4ee259	25864bc1-ebe0-4b33-92c4-8e81f479a18d	1.000	piece
d57fee08-890c-4b31-9925-b611eb4ee259	95ff2fa0-ff52-4961-836a-6984ba7add98	3.000	clove
d57fee08-890c-4b31-9925-b611eb4ee259	de9ff794-b346-47ca-9383-df0bfba09478	15.000	g
d57fee08-890c-4b31-9925-b611eb4ee259	f45f8e71-2fc6-41b0-aeec-559aec2a74a8	2.000	tbsp
d57fee08-890c-4b31-9925-b611eb4ee259	0b7b1ddb-9929-4352-9924-0ca61a7a3b59	200.000	g
d57fee08-890c-4b31-9925-b611eb4ee259	0dafbe10-2d43-4b04-ae62-43c02a6617ec	1.000	cup
0c161c39-c237-45f1-a8e6-9646fb0fbb41	82090119-5b09-4c87-8af4-b0c63ab75a3a	4.000	piece
0c161c39-c237-45f1-a8e6-9646fb0fbb41	c5be005b-8c20-45f7-8293-053ba6f5f95d	400.000	g
0c161c39-c237-45f1-a8e6-9646fb0fbb41	0dafbe10-2d43-4b04-ae62-43c02a6617ec	0.500	cup
0c161c39-c237-45f1-a8e6-9646fb0fbb41	0b7b1ddb-9929-4352-9924-0ca61a7a3b59	200.000	g
0c161c39-c237-45f1-a8e6-9646fb0fbb41	25864bc1-ebe0-4b33-92c4-8e81f479a18d	1.000	piece
0c161c39-c237-45f1-a8e6-9646fb0fbb41	645bcd1c-a04a-4498-9541-21a9ea7d3447	60.000	g
16b42f5e-ef62-41ce-8173-689364aab67b	d264ca43-6833-40ba-8cf5-97594ec7ed5e	500.000	g
16b42f5e-ef62-41ce-8173-689364aab67b	57a086d7-a00f-4e41-84ac-e6a0cc2e5663	50.000	g
16b42f5e-ef62-41ce-8173-689364aab67b	1d8538a5-2082-4d35-99bf-843ed8c18e3c	1.000	piece
16b42f5e-ef62-41ce-8173-689364aab67b	e0c7a66e-0716-43c1-8027-b1e721108d5b	30.000	g
16b42f5e-ef62-41ce-8173-689364aab67b	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
16b42f5e-ef62-41ce-8173-689364aab67b	c4bef9db-8cbd-4b30-b5aa-acdd7f9ac8c3	400.000	g
16b42f5e-ef62-41ce-8173-689364aab67b	73b9bf7c-b87b-4892-a32c-089c2e103d00	10.000	g
815b25ac-172d-4ace-93f8-bbfba78d3cbb	2b6db454-cfdd-4105-bbb7-75b71fa8eb27	300.000	g
815b25ac-172d-4ace-93f8-bbfba78d3cbb	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tbsp
815b25ac-172d-4ace-93f8-bbfba78d3cbb	8f897f2e-ef63-4dbd-9baf-284dddde8a96	1.000	piece
815b25ac-172d-4ace-93f8-bbfba78d3cbb	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
815b25ac-172d-4ace-93f8-bbfba78d3cbb	33e1b06a-65c1-4277-a26b-89a1964e47a5	200.000	g
f14e5642-72b4-45ac-8f19-12aa135d3681	8a2618a7-1fb5-4fd4-9326-62336adc3508	300.000	g
f14e5642-72b4-45ac-8f19-12aa135d3681	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tbsp
f14e5642-72b4-45ac-8f19-12aa135d3681	8f897f2e-ef63-4dbd-9baf-284dddde8a96	1.000	piece
f14e5642-72b4-45ac-8f19-12aa135d3681	57a086d7-a00f-4e41-84ac-e6a0cc2e5663	40.000	g
f14e5642-72b4-45ac-8f19-12aa135d3681	73b9bf7c-b87b-4892-a32c-089c2e103d00	5.000	g
f14e5642-72b4-45ac-8f19-12aa135d3681	95ff2fa0-ff52-4961-836a-6984ba7add98	1.000	clove
a934d358-7d10-492f-a3de-e2d5073aa03b	6665d4dd-2e53-4c42-a259-247ea6adcf35	300.000	g
a934d358-7d10-492f-a3de-e2d5073aa03b	44d967f0-d877-42b4-ab3c-10c46941b746	1.000	tsp
a934d358-7d10-492f-a3de-e2d5073aa03b	45ec108e-6d34-4295-a61f-c2aea959e8ac	2.000	tbsp
a934d358-7d10-492f-a3de-e2d5073aa03b	3837182b-4acc-401b-beb5-0db0de087bc3	15.000	g
a934d358-7d10-492f-a3de-e2d5073aa03b	0c9d3ca9-2cfc-438e-88e2-493fd7fe5778	15.000	g
807c0131-350c-4dcb-b5e7-572c3a323dd1	d2ae29d7-17a4-40db-89e8-b20c8f698488	350.000	g
807c0131-350c-4dcb-b5e7-572c3a323dd1	b75a7fb9-17cd-4bd3-8463-368f0312e201	2.000	tbsp
807c0131-350c-4dcb-b5e7-572c3a323dd1	95ff2fa0-ff52-4961-836a-6984ba7add98	3.000	clove
807c0131-350c-4dcb-b5e7-572c3a323dd1	8f897f2e-ef63-4dbd-9baf-284dddde8a96	0.500	piece
807c0131-350c-4dcb-b5e7-572c3a323dd1	73b9bf7c-b87b-4892-a32c-089c2e103d00	10.000	g
807c0131-350c-4dcb-b5e7-572c3a323dd1	f885e5af-eee5-44b5-9f91-58ed0b8fec09	0.250	tsp
9f5e8033-7b4e-40f8-b110-7d97907cc12f	8a2618a7-1fb5-4fd4-9326-62336adc3508	350.000	g
9f5e8033-7b4e-40f8-b110-7d97907cc12f	d5aeb1bd-2947-43b4-9db4-e61457dd759d	6.000	piece
9f5e8033-7b4e-40f8-b110-7d97907cc12f	d7a92616-af91-4afe-ab01-042e794e15b4	150.000	g
9f5e8033-7b4e-40f8-b110-7d97907cc12f	874cf0f6-362c-48b4-b099-36915c5ec35b	1.000	piece
9f5e8033-7b4e-40f8-b110-7d97907cc12f	6cf8dd84-bc6e-4e68-878c-6c115bb36862	60.000	g
9f5e8033-7b4e-40f8-b110-7d97907cc12f	b6f720c8-2e7b-4f8e-adb4-b57022d99a0f	1.000	piece
9f5e8033-7b4e-40f8-b110-7d97907cc12f	f0a44300-564a-40b0-8990-7d5089ff1d3a	10.000	g
b94a2523-8f7c-4e34-9f3c-97012d894236	82090119-5b09-4c87-8af4-b0c63ab75a3a	1.000	piece
b94a2523-8f7c-4e34-9f3c-97012d894236	2c43a12f-f532-4df7-b55b-6c312d689340	150.000	g
b94a2523-8f7c-4e34-9f3c-97012d894236	12e0c381-f45a-4d26-866f-47012609b45e	1.000	piece
b94a2523-8f7c-4e34-9f3c-97012d894236	45ec108e-6d34-4295-a61f-c2aea959e8ac	2.000	tbsp
b94a2523-8f7c-4e34-9f3c-97012d894236	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
b94a2523-8f7c-4e34-9f3c-97012d894236	de9ff794-b346-47ca-9383-df0bfba09478	10.000	g
b94a2523-8f7c-4e34-9f3c-97012d894236	44d967f0-d877-42b4-ab3c-10c46941b746	1.000	tsp
b94a2523-8f7c-4e34-9f3c-97012d894236	0dafbe10-2d43-4b04-ae62-43c02a6617ec	0.500	cup
92649054-941a-4101-98c7-cf630b94c3c8	579b7337-d801-4dc9-b599-508912450440	4.000	piece
92649054-941a-4101-98c7-cf630b94c3c8	d91abeb4-8b86-4567-85e1-b3c576bf68bc	2.000	cup
92649054-941a-4101-98c7-cf630b94c3c8	f6576856-fb2a-4789-a7a8-0daef7f9949f	60.000	g
92649054-941a-4101-98c7-cf630b94c3c8	57a086d7-a00f-4e41-84ac-e6a0cc2e5663	30.000	g
92649054-941a-4101-98c7-cf630b94c3c8	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
92649054-941a-4101-98c7-cf630b94c3c8	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tbsp
026effe9-98b1-4483-bd8a-31c4c6a280af	aa53b8ba-121c-4cde-af29-a3a0be157270	3.000	slice
026effe9-98b1-4483-bd8a-31c4c6a280af	98050983-dc6a-4dc4-831d-5a3ed5541e5d	100.000	g
026effe9-98b1-4483-bd8a-31c4c6a280af	9f29da31-fc50-4255-9f46-3eea489efbe3	2.000	slice
026effe9-98b1-4483-bd8a-31c4c6a280af	66eb1a53-79a4-4a4c-8bb8-25fe823055c6	20.000	g
026effe9-98b1-4483-bd8a-31c4c6a280af	5086c70a-eb85-4e61-aa8d-e81ce1167a03	0.500	piece
026effe9-98b1-4483-bd8a-31c4c6a280af	f3244cab-948a-43e9-9d33-514996ddee16	1.000	tbsp
58096b55-e187-4053-a651-86cf973c5901	aa53b8ba-121c-4cde-af29-a3a0be157270	2.000	slice
58096b55-e187-4053-a651-86cf973c5901	82a7642e-d453-4360-ae0c-de1328d37580	80.000	g
58096b55-e187-4053-a651-86cf973c5901	5086c70a-eb85-4e61-aa8d-e81ce1167a03	1.000	piece
58096b55-e187-4053-a651-86cf973c5901	43cbf2d3-7165-438e-9d6a-9df5afc83ec4	5.000	g
58096b55-e187-4053-a651-86cf973c5901	da0566f8-8a43-4429-b0db-a3a94942a9d3	1.000	tsp
816b5378-aa22-4a80-a8d9-08374ab87933	8ca5c6e4-0495-45c9-b0d0-6f46a1b5f51f	8.000	slice
816b5378-aa22-4a80-a8d9-08374ab87933	5086c70a-eb85-4e61-aa8d-e81ce1167a03	3.000	piece
816b5378-aa22-4a80-a8d9-08374ab87933	43cbf2d3-7165-438e-9d6a-9df5afc83ec4	10.000	g
816b5378-aa22-4a80-a8d9-08374ab87933	95ff2fa0-ff52-4961-836a-6984ba7add98	1.000	clove
816b5378-aa22-4a80-a8d9-08374ab87933	da0566f8-8a43-4429-b0db-a3a94942a9d3	2.000	tbsp
68cd36a5-aef0-4385-9481-5fe930d7ea0c	a3bdab62-9e64-4377-8761-f8bcd0cb91d2	400.000	g
68cd36a5-aef0-4385-9481-5fe930d7ea0c	e489a9b7-4df7-4d1c-b736-6fee915e9ae7	4.000	tbsp
68cd36a5-aef0-4385-9481-5fe930d7ea0c	95ff2fa0-ff52-4961-836a-6984ba7add98	2.000	clove
68cd36a5-aef0-4385-9481-5fe930d7ea0c	57a086d7-a00f-4e41-84ac-e6a0cc2e5663	30.000	g
68cd36a5-aef0-4385-9481-5fe930d7ea0c	e0c7a66e-0716-43c1-8027-b1e721108d5b	30.000	g
686e8a44-b024-47fb-8234-53993287656e	8e80d460-222c-4969-83c7-7d3bd8ef2979	200.000	g
686e8a44-b024-47fb-8234-53993287656e	a7ef29ff-a2c2-4861-98e4-64aa261fb8c8	1.000	cup
686e8a44-b024-47fb-8234-53993287656e	75f64318-0e35-4497-922b-cef681139d83	1.000	tbsp
686e8a44-b024-47fb-8234-53993287656e	be39aa1e-2b5d-4da0-bc4e-f05b09216616	0.250	cup
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	b4533f1f-9c8e-47fe-9341-1f3e9e370b83	1.000	cup
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	0e4d9d9a-37e9-482b-89dd-2ab597222cc7	4.000	tbsp
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	a4bcc641-2afb-4ef4-b6a1-6caa3a24c409	50.000	g
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	75f64318-0e35-4497-922b-cef681139d83	3.000	tbsp
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	f43f4e55-e108-4ac9-a9a3-0b5127659e3c	2.000	tbsp
c14d8f43-9f79-4849-9b63-8799a2185fc3	a9a1bad9-4eca-43e7-b6d7-ee335e2702c8	250.000	g
c14d8f43-9f79-4849-9b63-8799a2185fc3	a75ae202-b7d5-4882-be33-0635029521c2	3.000	piece
c14d8f43-9f79-4849-9b63-8799a2185fc3	1d8538a5-2082-4d35-99bf-843ed8c18e3c	2.000	piece
c14d8f43-9f79-4849-9b63-8799a2185fc3	75f64318-0e35-4497-922b-cef681139d83	4.000	tbsp
c14d8f43-9f79-4849-9b63-8799a2185fc3	457f1060-ef40-4a5b-a2df-85f2e1d7a435	60.000	g
c14d8f43-9f79-4849-9b63-8799a2185fc3	9142f0e2-55d3-4ee9-8cf9-edfb498c9313	1.500	tsp
c14d8f43-9f79-4849-9b63-8799a2185fc3	b75a7fb9-17cd-4bd3-8463-368f0312e201	60.000	g
7409b248-a723-48d5-b993-272de6b18346	a9a1bad9-4eca-43e7-b6d7-ee335e2702c8	300.000	g
7409b248-a723-48d5-b993-272de6b18346	c40b9b15-b3de-4f89-ade2-869397a239a5	1.500	cup
7409b248-a723-48d5-b993-272de6b18346	1d8538a5-2082-4d35-99bf-843ed8c18e3c	2.000	piece
7409b248-a723-48d5-b993-272de6b18346	8ab706f2-1c77-478a-9e31-e1d04f27224c	200.000	ml
7409b248-a723-48d5-b993-272de6b18346	75f64318-0e35-4497-922b-cef681139d83	4.000	tbsp
7409b248-a723-48d5-b993-272de6b18346	9142f0e2-55d3-4ee9-8cf9-edfb498c9313	2.000	tsp
7409b248-a723-48d5-b993-272de6b18346	b75a7fb9-17cd-4bd3-8463-368f0312e201	80.000	g
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	a7ef29ff-a2c2-4861-98e4-64aa261fb8c8	1.000	cup
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	a75ae202-b7d5-4882-be33-0635029521c2	1.000	piece
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	8e80d460-222c-4969-83c7-7d3bd8ef2979	150.000	g
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	8ab706f2-1c77-478a-9e31-e1d04f27224c	150.000	ml
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	75f64318-0e35-4497-922b-cef681139d83	1.000	tbsp
58b9fd50-9ae8-4f29-b61c-344218bc98f5	d91abeb4-8b86-4567-85e1-b3c576bf68bc	2.000	cup
58b9fd50-9ae8-4f29-b61c-344218bc98f5	a75ae202-b7d5-4882-be33-0635029521c2	1.000	piece
58b9fd50-9ae8-4f29-b61c-344218bc98f5	6d9cb726-a970-4304-8478-7a743b3ffc3e	1.000	piece
58b9fd50-9ae8-4f29-b61c-344218bc98f5	80b87ca3-1251-4761-a315-e866c230c08b	200.000	ml
58b9fd50-9ae8-4f29-b61c-344218bc98f5	f43f4e55-e108-4ac9-a9a3-0b5127659e3c	1.000	tbsp
bed7dd31-1676-4af4-9117-9efd1f0607d7	f4782639-7872-4b98-8db0-49fa4aac8d04	1.000	tsp
bed7dd31-1676-4af4-9117-9efd1f0607d7	8ab706f2-1c77-478a-9e31-e1d04f27224c	200.000	ml
bed7dd31-1676-4af4-9117-9efd1f0607d7	75f64318-0e35-4497-922b-cef681139d83	1.000	tsp
1503796f-f108-4270-9fbe-7b1516c0a18d	c59a079b-bdf8-4fd9-a872-0669e95feab4	1.000	piece
1503796f-f108-4270-9fbe-7b1516c0a18d	8e80d460-222c-4969-83c7-7d3bd8ef2979	150.000	g
1503796f-f108-4270-9fbe-7b1516c0a18d	8ab706f2-1c77-478a-9e31-e1d04f27224c	100.000	ml
1503796f-f108-4270-9fbe-7b1516c0a18d	75f64318-0e35-4497-922b-cef681139d83	1.000	tsp
\.


--
-- Data for Name: recipe_tag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipe_tag (recipe_id, tag_id) FROM stdin;
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	1835bc6b-a8a1-4b40-85fa-a203dc47cf90
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	dc2c93b5-7f2b-4e05-aa33-54630913f2ad
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	3de140eb-68c9-4545-9d11-09f1250a1c9b
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	c0ea566a-34e8-4789-a45b-d5fb7e62551c
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	badc51b5-2b17-40cf-9ddc-7f109efda359
f0a27d79-9924-4e4d-bfcc-b64119c1a58b	fff848ab-d932-4226-b903-6dd676a157e9
90627aea-d9f9-46ff-bd2a-21112d6feaad	1835bc6b-a8a1-4b40-85fa-a203dc47cf90
90627aea-d9f9-46ff-bd2a-21112d6feaad	dc2c93b5-7f2b-4e05-aa33-54630913f2ad
90627aea-d9f9-46ff-bd2a-21112d6feaad	45370bb9-2583-4e09-9546-e1b8ce293eda
90627aea-d9f9-46ff-bd2a-21112d6feaad	3de140eb-68c9-4545-9d11-09f1250a1c9b
90627aea-d9f9-46ff-bd2a-21112d6feaad	12483c1a-d4bf-4da7-8899-04225bf4dcbb
90627aea-d9f9-46ff-bd2a-21112d6feaad	c0ea566a-34e8-4789-a45b-d5fb7e62551c
90627aea-d9f9-46ff-bd2a-21112d6feaad	13a75c7a-6e7d-41c9-89f6-562f21da2d95
90627aea-d9f9-46ff-bd2a-21112d6feaad	fff848ab-d932-4226-b903-6dd676a157e9
d67e7969-8efe-4e9a-82be-9ff4d85fc571	1835bc6b-a8a1-4b40-85fa-a203dc47cf90
d67e7969-8efe-4e9a-82be-9ff4d85fc571	dc2c93b5-7f2b-4e05-aa33-54630913f2ad
d67e7969-8efe-4e9a-82be-9ff4d85fc571	3de140eb-68c9-4545-9d11-09f1250a1c9b
d67e7969-8efe-4e9a-82be-9ff4d85fc571	c0ea566a-34e8-4789-a45b-d5fb7e62551c
d67e7969-8efe-4e9a-82be-9ff4d85fc571	fff848ab-d932-4226-b903-6dd676a157e9
d67e7969-8efe-4e9a-82be-9ff4d85fc571	13a75c7a-6e7d-41c9-89f6-562f21da2d95
d67e7969-8efe-4e9a-82be-9ff4d85fc571	77b878e7-1631-4fff-b12a-03001d07ef4a
71551f3d-b1e1-45f4-ab74-266b7479c55d	1835bc6b-a8a1-4b40-85fa-a203dc47cf90
71551f3d-b1e1-45f4-ab74-266b7479c55d	dc2c93b5-7f2b-4e05-aa33-54630913f2ad
71551f3d-b1e1-45f4-ab74-266b7479c55d	3de140eb-68c9-4545-9d11-09f1250a1c9b
71551f3d-b1e1-45f4-ab74-266b7479c55d	12483c1a-d4bf-4da7-8899-04225bf4dcbb
71551f3d-b1e1-45f4-ab74-266b7479c55d	17676826-9ab2-47a0-b925-36867ffcb8cd
71551f3d-b1e1-45f4-ab74-266b7479c55d	c0ea566a-34e8-4789-a45b-d5fb7e62551c
71551f3d-b1e1-45f4-ab74-266b7479c55d	badc51b5-2b17-40cf-9ddc-7f109efda359
71551f3d-b1e1-45f4-ab74-266b7479c55d	13a75c7a-6e7d-41c9-89f6-562f21da2d95
fd48d17b-86df-4000-9799-6933b6873f81	1835bc6b-a8a1-4b40-85fa-a203dc47cf90
fd48d17b-86df-4000-9799-6933b6873f81	dc2c93b5-7f2b-4e05-aa33-54630913f2ad
fd48d17b-86df-4000-9799-6933b6873f81	3de140eb-68c9-4545-9d11-09f1250a1c9b
fd48d17b-86df-4000-9799-6933b6873f81	12483c1a-d4bf-4da7-8899-04225bf4dcbb
fd48d17b-86df-4000-9799-6933b6873f81	badc51b5-2b17-40cf-9ddc-7f109efda359
fd48d17b-86df-4000-9799-6933b6873f81	13a75c7a-6e7d-41c9-89f6-562f21da2d95
fd48d17b-86df-4000-9799-6933b6873f81	fff848ab-d932-4226-b903-6dd676a157e9
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	1835bc6b-a8a1-4b40-85fa-a203dc47cf90
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	d28ee3f6-4e0e-4cdb-b7d5-09048b1f91e8
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	c0ea566a-34e8-4789-a45b-d5fb7e62551c
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	fff848ab-d932-4226-b903-6dd676a157e9
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	13a75c7a-6e7d-41c9-89f6-562f21da2d95
72b5ae4c-cba4-41b8-8e8d-8c2e56d70e65	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
1b55a005-6344-4714-9aa7-97837cca2086	1835bc6b-a8a1-4b40-85fa-a203dc47cf90
1b55a005-6344-4714-9aa7-97837cca2086	d28ee3f6-4e0e-4cdb-b7d5-09048b1f91e8
1b55a005-6344-4714-9aa7-97837cca2086	fff848ab-d932-4226-b903-6dd676a157e9
1b55a005-6344-4714-9aa7-97837cca2086	badc51b5-2b17-40cf-9ddc-7f109efda359
1b55a005-6344-4714-9aa7-97837cca2086	13a75c7a-6e7d-41c9-89f6-562f21da2d95
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	f92f7430-6271-4050-a9dd-191c88d6c520
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	d28ee3f6-4e0e-4cdb-b7d5-09048b1f91e8
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	2f97a990-b1b7-4716-9404-45f393ca3e97
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	12483c1a-d4bf-4da7-8899-04225bf4dcbb
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	fff848ab-d932-4226-b903-6dd676a157e9
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	13a75c7a-6e7d-41c9-89f6-562f21da2d95
ef6b4b50-9cfa-4e26-917f-39ac2aee443d	badc51b5-2b17-40cf-9ddc-7f109efda359
74e74a2f-3579-4619-a911-fd5af69f6fd7	f92f7430-6271-4050-a9dd-191c88d6c520
74e74a2f-3579-4619-a911-fd5af69f6fd7	d28ee3f6-4e0e-4cdb-b7d5-09048b1f91e8
74e74a2f-3579-4619-a911-fd5af69f6fd7	2f97a990-b1b7-4716-9404-45f393ca3e97
74e74a2f-3579-4619-a911-fd5af69f6fd7	12483c1a-d4bf-4da7-8899-04225bf4dcbb
74e74a2f-3579-4619-a911-fd5af69f6fd7	fff848ab-d932-4226-b903-6dd676a157e9
74e74a2f-3579-4619-a911-fd5af69f6fd7	badc51b5-2b17-40cf-9ddc-7f109efda359
8f48e7b7-611c-428b-899a-a1ca55f41779	1835bc6b-a8a1-4b40-85fa-a203dc47cf90
8f48e7b7-611c-428b-899a-a1ca55f41779	d28ee3f6-4e0e-4cdb-b7d5-09048b1f91e8
8f48e7b7-611c-428b-899a-a1ca55f41779	3de140eb-68c9-4545-9d11-09f1250a1c9b
8f48e7b7-611c-428b-899a-a1ca55f41779	fff848ab-d932-4226-b903-6dd676a157e9
8f48e7b7-611c-428b-899a-a1ca55f41779	badc51b5-2b17-40cf-9ddc-7f109efda359
8f48e7b7-611c-428b-899a-a1ca55f41779	13a75c7a-6e7d-41c9-89f6-562f21da2d95
a8b44445-3f32-4ab8-88e0-34c72fc1671b	35f9fc5d-f740-43c4-bc4e-f0a6b35dc892
a8b44445-3f32-4ab8-88e0-34c72fc1671b	2f97a990-b1b7-4716-9404-45f393ca3e97
a8b44445-3f32-4ab8-88e0-34c72fc1671b	56c468ca-2f4f-415e-ba60-1fdcdce88c74
a8b44445-3f32-4ab8-88e0-34c72fc1671b	3de140eb-68c9-4545-9d11-09f1250a1c9b
a8b44445-3f32-4ab8-88e0-34c72fc1671b	17676826-9ab2-47a0-b925-36867ffcb8cd
a8b44445-3f32-4ab8-88e0-34c72fc1671b	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
a8b44445-3f32-4ab8-88e0-34c72fc1671b	c0ea566a-34e8-4789-a45b-d5fb7e62551c
a8b44445-3f32-4ab8-88e0-34c72fc1671b	13a75c7a-6e7d-41c9-89f6-562f21da2d95
5f660db5-8f5d-4401-a53c-563ff59dc677	35f9fc5d-f740-43c4-bc4e-f0a6b35dc892
5f660db5-8f5d-4401-a53c-563ff59dc677	2f97a990-b1b7-4716-9404-45f393ca3e97
5f660db5-8f5d-4401-a53c-563ff59dc677	56c468ca-2f4f-415e-ba60-1fdcdce88c74
5f660db5-8f5d-4401-a53c-563ff59dc677	12483c1a-d4bf-4da7-8899-04225bf4dcbb
5f660db5-8f5d-4401-a53c-563ff59dc677	fff848ab-d932-4226-b903-6dd676a157e9
5f660db5-8f5d-4401-a53c-563ff59dc677	13a75c7a-6e7d-41c9-89f6-562f21da2d95
5f660db5-8f5d-4401-a53c-563ff59dc677	badc51b5-2b17-40cf-9ddc-7f109efda359
6cf92b55-c01f-4e77-a088-81d8bab48af8	35f9fc5d-f740-43c4-bc4e-f0a6b35dc892
6cf92b55-c01f-4e77-a088-81d8bab48af8	2f97a990-b1b7-4716-9404-45f393ca3e97
6cf92b55-c01f-4e77-a088-81d8bab48af8	56c468ca-2f4f-415e-ba60-1fdcdce88c74
6cf92b55-c01f-4e77-a088-81d8bab48af8	3de140eb-68c9-4545-9d11-09f1250a1c9b
6cf92b55-c01f-4e77-a088-81d8bab48af8	12483c1a-d4bf-4da7-8899-04225bf4dcbb
6cf92b55-c01f-4e77-a088-81d8bab48af8	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
6cf92b55-c01f-4e77-a088-81d8bab48af8	13a75c7a-6e7d-41c9-89f6-562f21da2d95
76af319d-ef28-454e-8e8b-f1d8305bafc4	35f9fc5d-f740-43c4-bc4e-f0a6b35dc892
76af319d-ef28-454e-8e8b-f1d8305bafc4	2f97a990-b1b7-4716-9404-45f393ca3e97
76af319d-ef28-454e-8e8b-f1d8305bafc4	12483c1a-d4bf-4da7-8899-04225bf4dcbb
76af319d-ef28-454e-8e8b-f1d8305bafc4	17676826-9ab2-47a0-b925-36867ffcb8cd
76af319d-ef28-454e-8e8b-f1d8305bafc4	c0ea566a-34e8-4789-a45b-d5fb7e62551c
76af319d-ef28-454e-8e8b-f1d8305bafc4	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
76af319d-ef28-454e-8e8b-f1d8305bafc4	badc51b5-2b17-40cf-9ddc-7f109efda359
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	35f9fc5d-f740-43c4-bc4e-f0a6b35dc892
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	2f97a990-b1b7-4716-9404-45f393ca3e97
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	3de140eb-68c9-4545-9d11-09f1250a1c9b
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	17676826-9ab2-47a0-b925-36867ffcb8cd
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	c0ea566a-34e8-4789-a45b-d5fb7e62551c
2f09ff6e-9e7c-46f1-93aa-f5c07aed6324	13a75c7a-6e7d-41c9-89f6-562f21da2d95
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	f92f7430-6271-4050-a9dd-191c88d6c520
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	2f97a990-b1b7-4716-9404-45f393ca3e97
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	56c468ca-2f4f-415e-ba60-1fdcdce88c74
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	3de140eb-68c9-4545-9d11-09f1250a1c9b
dfee4908-88b5-4f41-8d09-7d0871e5d6fc	13a75c7a-6e7d-41c9-89f6-562f21da2d95
91625d88-13da-4b3e-bffe-642468e12642	f92f7430-6271-4050-a9dd-191c88d6c520
91625d88-13da-4b3e-bffe-642468e12642	2f97a990-b1b7-4716-9404-45f393ca3e97
91625d88-13da-4b3e-bffe-642468e12642	56c468ca-2f4f-415e-ba60-1fdcdce88c74
91625d88-13da-4b3e-bffe-642468e12642	12483c1a-d4bf-4da7-8899-04225bf4dcbb
91625d88-13da-4b3e-bffe-642468e12642	fff848ab-d932-4226-b903-6dd676a157e9
91625d88-13da-4b3e-bffe-642468e12642	badc51b5-2b17-40cf-9ddc-7f109efda359
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	f92f7430-6271-4050-a9dd-191c88d6c520
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	2f97a990-b1b7-4716-9404-45f393ca3e97
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	56c468ca-2f4f-415e-ba60-1fdcdce88c74
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	3de140eb-68c9-4545-9d11-09f1250a1c9b
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	b2697197-0221-48d9-95bd-c8f6ce4ab8b5
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
b96aa0f6-2a09-46dd-bd6e-22478bfdd743	12483c1a-d4bf-4da7-8899-04225bf4dcbb
f38548d2-d155-4fec-9617-e9ac40e02a07	f92f7430-6271-4050-a9dd-191c88d6c520
f38548d2-d155-4fec-9617-e9ac40e02a07	2f97a990-b1b7-4716-9404-45f393ca3e97
f38548d2-d155-4fec-9617-e9ac40e02a07	56c468ca-2f4f-415e-ba60-1fdcdce88c74
f38548d2-d155-4fec-9617-e9ac40e02a07	3de140eb-68c9-4545-9d11-09f1250a1c9b
f38548d2-d155-4fec-9617-e9ac40e02a07	13a75c7a-6e7d-41c9-89f6-562f21da2d95
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	f92f7430-6271-4050-a9dd-191c88d6c520
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	2f97a990-b1b7-4716-9404-45f393ca3e97
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	56c468ca-2f4f-415e-ba60-1fdcdce88c74
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	3de140eb-68c9-4545-9d11-09f1250a1c9b
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	b2697197-0221-48d9-95bd-c8f6ce4ab8b5
ed3bc71b-bb0e-4dcf-8e65-60b40e0710ee	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
6d1f2df4-0033-4df1-84f8-81766fdab681	f92f7430-6271-4050-a9dd-191c88d6c520
6d1f2df4-0033-4df1-84f8-81766fdab681	56c468ca-2f4f-415e-ba60-1fdcdce88c74
6d1f2df4-0033-4df1-84f8-81766fdab681	fff848ab-d932-4226-b903-6dd676a157e9
6d1f2df4-0033-4df1-84f8-81766fdab681	13a75c7a-6e7d-41c9-89f6-562f21da2d95
e8c73af2-eee6-46f8-8932-2dfa7335216c	f92f7430-6271-4050-a9dd-191c88d6c520
e8c73af2-eee6-46f8-8932-2dfa7335216c	56c468ca-2f4f-415e-ba60-1fdcdce88c74
e8c73af2-eee6-46f8-8932-2dfa7335216c	12483c1a-d4bf-4da7-8899-04225bf4dcbb
e8c73af2-eee6-46f8-8932-2dfa7335216c	fff848ab-d932-4226-b903-6dd676a157e9
e8c73af2-eee6-46f8-8932-2dfa7335216c	13a75c7a-6e7d-41c9-89f6-562f21da2d95
e84c5f38-9e4c-4cc7-8570-949a449019a1	f92f7430-6271-4050-a9dd-191c88d6c520
e84c5f38-9e4c-4cc7-8570-949a449019a1	56c468ca-2f4f-415e-ba60-1fdcdce88c74
e84c5f38-9e4c-4cc7-8570-949a449019a1	2f97a990-b1b7-4716-9404-45f393ca3e97
e84c5f38-9e4c-4cc7-8570-949a449019a1	3de140eb-68c9-4545-9d11-09f1250a1c9b
e84c5f38-9e4c-4cc7-8570-949a449019a1	c0ea566a-34e8-4789-a45b-d5fb7e62551c
e84c5f38-9e4c-4cc7-8570-949a449019a1	fff848ab-d932-4226-b903-6dd676a157e9
e84c5f38-9e4c-4cc7-8570-949a449019a1	13a75c7a-6e7d-41c9-89f6-562f21da2d95
e84c5f38-9e4c-4cc7-8570-949a449019a1	77b878e7-1631-4fff-b12a-03001d07ef4a
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	26c16040-656a-411d-a7f8-66160125d7f8
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	56c468ca-2f4f-415e-ba60-1fdcdce88c74
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	12483c1a-d4bf-4da7-8899-04225bf4dcbb
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	c0ea566a-34e8-4789-a45b-d5fb7e62551c
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	fff848ab-d932-4226-b903-6dd676a157e9
c9e6d1f9-7f1e-4e2a-a5dc-723f341859f9	f9091468-45e9-47cc-9762-74b2609edc08
32ec3894-ff68-4ebb-994f-a32c00c9c98c	26c16040-656a-411d-a7f8-66160125d7f8
32ec3894-ff68-4ebb-994f-a32c00c9c98c	56c468ca-2f4f-415e-ba60-1fdcdce88c74
32ec3894-ff68-4ebb-994f-a32c00c9c98c	2f97a990-b1b7-4716-9404-45f393ca3e97
32ec3894-ff68-4ebb-994f-a32c00c9c98c	3de140eb-68c9-4545-9d11-09f1250a1c9b
32ec3894-ff68-4ebb-994f-a32c00c9c98c	fff848ab-d932-4226-b903-6dd676a157e9
32ec3894-ff68-4ebb-994f-a32c00c9c98c	13a75c7a-6e7d-41c9-89f6-562f21da2d95
2f36a55a-2dd4-49a5-ba21-07c29e397e46	f92f7430-6271-4050-a9dd-191c88d6c520
2f36a55a-2dd4-49a5-ba21-07c29e397e46	2f97a990-b1b7-4716-9404-45f393ca3e97
2f36a55a-2dd4-49a5-ba21-07c29e397e46	56c468ca-2f4f-415e-ba60-1fdcdce88c74
2f36a55a-2dd4-49a5-ba21-07c29e397e46	12483c1a-d4bf-4da7-8899-04225bf4dcbb
2f36a55a-2dd4-49a5-ba21-07c29e397e46	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	f92f7430-6271-4050-a9dd-191c88d6c520
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	56c468ca-2f4f-415e-ba60-1fdcdce88c74
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	12483c1a-d4bf-4da7-8899-04225bf4dcbb
511cc8d8-2cec-4bdb-a9e5-57a7949afd1d	e5312f1a-62cf-4588-b6d8-d8274f07c86f
d57fee08-890c-4b31-9925-b611eb4ee259	f92f7430-6271-4050-a9dd-191c88d6c520
d57fee08-890c-4b31-9925-b611eb4ee259	56c468ca-2f4f-415e-ba60-1fdcdce88c74
d57fee08-890c-4b31-9925-b611eb4ee259	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
0c161c39-c237-45f1-a8e6-9646fb0fbb41	26c16040-656a-411d-a7f8-66160125d7f8
0c161c39-c237-45f1-a8e6-9646fb0fbb41	56c468ca-2f4f-415e-ba60-1fdcdce88c74
0c161c39-c237-45f1-a8e6-9646fb0fbb41	12483c1a-d4bf-4da7-8899-04225bf4dcbb
0c161c39-c237-45f1-a8e6-9646fb0fbb41	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
0c161c39-c237-45f1-a8e6-9646fb0fbb41	13a75c7a-6e7d-41c9-89f6-562f21da2d95
16b42f5e-ef62-41ce-8173-689364aab67b	26c16040-656a-411d-a7f8-66160125d7f8
16b42f5e-ef62-41ce-8173-689364aab67b	56c468ca-2f4f-415e-ba60-1fdcdce88c74
16b42f5e-ef62-41ce-8173-689364aab67b	12483c1a-d4bf-4da7-8899-04225bf4dcbb
16b42f5e-ef62-41ce-8173-689364aab67b	fff848ab-d932-4226-b903-6dd676a157e9
16b42f5e-ef62-41ce-8173-689364aab67b	badc51b5-2b17-40cf-9ddc-7f109efda359
16b42f5e-ef62-41ce-8173-689364aab67b	13a75c7a-6e7d-41c9-89f6-562f21da2d95
815b25ac-172d-4ace-93f8-bbfba78d3cbb	f92f7430-6271-4050-a9dd-191c88d6c520
815b25ac-172d-4ace-93f8-bbfba78d3cbb	56c468ca-2f4f-415e-ba60-1fdcdce88c74
815b25ac-172d-4ace-93f8-bbfba78d3cbb	12483c1a-d4bf-4da7-8899-04225bf4dcbb
815b25ac-172d-4ace-93f8-bbfba78d3cbb	17676826-9ab2-47a0-b925-36867ffcb8cd
815b25ac-172d-4ace-93f8-bbfba78d3cbb	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
815b25ac-172d-4ace-93f8-bbfba78d3cbb	708e2a22-bc25-475f-94dc-30f8af0d48da
815b25ac-172d-4ace-93f8-bbfba78d3cbb	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
f14e5642-72b4-45ac-8f19-12aa135d3681	26c16040-656a-411d-a7f8-66160125d7f8
f14e5642-72b4-45ac-8f19-12aa135d3681	56c468ca-2f4f-415e-ba60-1fdcdce88c74
f14e5642-72b4-45ac-8f19-12aa135d3681	12483c1a-d4bf-4da7-8899-04225bf4dcbb
f14e5642-72b4-45ac-8f19-12aa135d3681	708e2a22-bc25-475f-94dc-30f8af0d48da
f14e5642-72b4-45ac-8f19-12aa135d3681	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
f14e5642-72b4-45ac-8f19-12aa135d3681	fff848ab-d932-4226-b903-6dd676a157e9
a934d358-7d10-492f-a3de-e2d5073aa03b	f92f7430-6271-4050-a9dd-191c88d6c520
a934d358-7d10-492f-a3de-e2d5073aa03b	56c468ca-2f4f-415e-ba60-1fdcdce88c74
a934d358-7d10-492f-a3de-e2d5073aa03b	12483c1a-d4bf-4da7-8899-04225bf4dcbb
a934d358-7d10-492f-a3de-e2d5073aa03b	17676826-9ab2-47a0-b925-36867ffcb8cd
a934d358-7d10-492f-a3de-e2d5073aa03b	708e2a22-bc25-475f-94dc-30f8af0d48da
a934d358-7d10-492f-a3de-e2d5073aa03b	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
a934d358-7d10-492f-a3de-e2d5073aa03b	b0ce49d7-5fca-4864-a265-0d6368cdc105
a934d358-7d10-492f-a3de-e2d5073aa03b	e5312f1a-62cf-4588-b6d8-d8274f07c86f
807c0131-350c-4dcb-b5e7-572c3a323dd1	f92f7430-6271-4050-a9dd-191c88d6c520
807c0131-350c-4dcb-b5e7-572c3a323dd1	56c468ca-2f4f-415e-ba60-1fdcdce88c74
807c0131-350c-4dcb-b5e7-572c3a323dd1	12483c1a-d4bf-4da7-8899-04225bf4dcbb
807c0131-350c-4dcb-b5e7-572c3a323dd1	17676826-9ab2-47a0-b925-36867ffcb8cd
807c0131-350c-4dcb-b5e7-572c3a323dd1	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
807c0131-350c-4dcb-b5e7-572c3a323dd1	f9091468-45e9-47cc-9762-74b2609edc08
807c0131-350c-4dcb-b5e7-572c3a323dd1	13a75c7a-6e7d-41c9-89f6-562f21da2d95
9f5e8033-7b4e-40f8-b110-7d97907cc12f	26c16040-656a-411d-a7f8-66160125d7f8
9f5e8033-7b4e-40f8-b110-7d97907cc12f	2f97a990-b1b7-4716-9404-45f393ca3e97
9f5e8033-7b4e-40f8-b110-7d97907cc12f	56c468ca-2f4f-415e-ba60-1fdcdce88c74
9f5e8033-7b4e-40f8-b110-7d97907cc12f	708e2a22-bc25-475f-94dc-30f8af0d48da
9f5e8033-7b4e-40f8-b110-7d97907cc12f	ce6f90d7-fcc1-419d-a81d-c9f6705cd72f
9f5e8033-7b4e-40f8-b110-7d97907cc12f	13a75c7a-6e7d-41c9-89f6-562f21da2d95
b94a2523-8f7c-4e34-9f3c-97012d894236	f92f7430-6271-4050-a9dd-191c88d6c520
b94a2523-8f7c-4e34-9f3c-97012d894236	56c468ca-2f4f-415e-ba60-1fdcdce88c74
b94a2523-8f7c-4e34-9f3c-97012d894236	2f97a990-b1b7-4716-9404-45f393ca3e97
b94a2523-8f7c-4e34-9f3c-97012d894236	3de140eb-68c9-4545-9d11-09f1250a1c9b
b94a2523-8f7c-4e34-9f3c-97012d894236	b2697197-0221-48d9-95bd-c8f6ce4ab8b5
b94a2523-8f7c-4e34-9f3c-97012d894236	c0ea566a-34e8-4789-a45b-d5fb7e62551c
b94a2523-8f7c-4e34-9f3c-97012d894236	e5312f1a-62cf-4588-b6d8-d8274f07c86f
92649054-941a-4101-98c7-cf630b94c3c8	26c16040-656a-411d-a7f8-66160125d7f8
92649054-941a-4101-98c7-cf630b94c3c8	56c468ca-2f4f-415e-ba60-1fdcdce88c74
92649054-941a-4101-98c7-cf630b94c3c8	3de140eb-68c9-4545-9d11-09f1250a1c9b
92649054-941a-4101-98c7-cf630b94c3c8	17676826-9ab2-47a0-b925-36867ffcb8cd
92649054-941a-4101-98c7-cf630b94c3c8	13a75c7a-6e7d-41c9-89f6-562f21da2d95
92649054-941a-4101-98c7-cf630b94c3c8	fff848ab-d932-4226-b903-6dd676a157e9
026effe9-98b1-4483-bd8a-31c4c6a280af	f92f7430-6271-4050-a9dd-191c88d6c520
026effe9-98b1-4483-bd8a-31c4c6a280af	2f97a990-b1b7-4716-9404-45f393ca3e97
026effe9-98b1-4483-bd8a-31c4c6a280af	12483c1a-d4bf-4da7-8899-04225bf4dcbb
026effe9-98b1-4483-bd8a-31c4c6a280af	fff848ab-d932-4226-b903-6dd676a157e9
026effe9-98b1-4483-bd8a-31c4c6a280af	badc51b5-2b17-40cf-9ddc-7f109efda359
58096b55-e187-4053-a651-86cf973c5901	f92f7430-6271-4050-a9dd-191c88d6c520
58096b55-e187-4053-a651-86cf973c5901	2f97a990-b1b7-4716-9404-45f393ca3e97
58096b55-e187-4053-a651-86cf973c5901	3de140eb-68c9-4545-9d11-09f1250a1c9b
58096b55-e187-4053-a651-86cf973c5901	c0ea566a-34e8-4789-a45b-d5fb7e62551c
58096b55-e187-4053-a651-86cf973c5901	fff848ab-d932-4226-b903-6dd676a157e9
58096b55-e187-4053-a651-86cf973c5901	13a75c7a-6e7d-41c9-89f6-562f21da2d95
816b5378-aa22-4a80-a8d9-08374ab87933	792971c4-51df-4bf8-8c66-5f50c6831a81
816b5378-aa22-4a80-a8d9-08374ab87933	45370bb9-2583-4e09-9546-e1b8ce293eda
816b5378-aa22-4a80-a8d9-08374ab87933	3de140eb-68c9-4545-9d11-09f1250a1c9b
816b5378-aa22-4a80-a8d9-08374ab87933	b2697197-0221-48d9-95bd-c8f6ce4ab8b5
816b5378-aa22-4a80-a8d9-08374ab87933	c0ea566a-34e8-4789-a45b-d5fb7e62551c
816b5378-aa22-4a80-a8d9-08374ab87933	fff848ab-d932-4226-b903-6dd676a157e9
68cd36a5-aef0-4385-9481-5fe930d7ea0c	792971c4-51df-4bf8-8c66-5f50c6831a81
68cd36a5-aef0-4385-9481-5fe930d7ea0c	45370bb9-2583-4e09-9546-e1b8ce293eda
68cd36a5-aef0-4385-9481-5fe930d7ea0c	3de140eb-68c9-4545-9d11-09f1250a1c9b
68cd36a5-aef0-4385-9481-5fe930d7ea0c	13a75c7a-6e7d-41c9-89f6-562f21da2d95
68cd36a5-aef0-4385-9481-5fe930d7ea0c	fff848ab-d932-4226-b903-6dd676a157e9
686e8a44-b024-47fb-8234-53993287656e	792971c4-51df-4bf8-8c66-5f50c6831a81
686e8a44-b024-47fb-8234-53993287656e	45370bb9-2583-4e09-9546-e1b8ce293eda
686e8a44-b024-47fb-8234-53993287656e	3de140eb-68c9-4545-9d11-09f1250a1c9b
686e8a44-b024-47fb-8234-53993287656e	12483c1a-d4bf-4da7-8899-04225bf4dcbb
686e8a44-b024-47fb-8234-53993287656e	c0ea566a-34e8-4789-a45b-d5fb7e62551c
686e8a44-b024-47fb-8234-53993287656e	13a75c7a-6e7d-41c9-89f6-562f21da2d95
686e8a44-b024-47fb-8234-53993287656e	fff848ab-d932-4226-b903-6dd676a157e9
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	792971c4-51df-4bf8-8c66-5f50c6831a81
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	45370bb9-2583-4e09-9546-e1b8ce293eda
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	3de140eb-68c9-4545-9d11-09f1250a1c9b
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	30868e77-77e3-4d0e-8d5d-7533373c1c7f
8ee32afe-008f-4f6f-a30b-186be6a5b3ed	fff848ab-d932-4226-b903-6dd676a157e9
c14d8f43-9f79-4849-9b63-8799a2185fc3	792971c4-51df-4bf8-8c66-5f50c6831a81
c14d8f43-9f79-4849-9b63-8799a2185fc3	dc2c93b5-7f2b-4e05-aa33-54630913f2ad
c14d8f43-9f79-4849-9b63-8799a2185fc3	45370bb9-2583-4e09-9546-e1b8ce293eda
c14d8f43-9f79-4849-9b63-8799a2185fc3	3de140eb-68c9-4545-9d11-09f1250a1c9b
c14d8f43-9f79-4849-9b63-8799a2185fc3	fff848ab-d932-4226-b903-6dd676a157e9
c14d8f43-9f79-4849-9b63-8799a2185fc3	badc51b5-2b17-40cf-9ddc-7f109efda359
c14d8f43-9f79-4849-9b63-8799a2185fc3	13a75c7a-6e7d-41c9-89f6-562f21da2d95
c14d8f43-9f79-4849-9b63-8799a2185fc3	77b878e7-1631-4fff-b12a-03001d07ef4a
7409b248-a723-48d5-b993-272de6b18346	792971c4-51df-4bf8-8c66-5f50c6831a81
7409b248-a723-48d5-b993-272de6b18346	dc2c93b5-7f2b-4e05-aa33-54630913f2ad
7409b248-a723-48d5-b993-272de6b18346	45370bb9-2583-4e09-9546-e1b8ce293eda
7409b248-a723-48d5-b993-272de6b18346	3de140eb-68c9-4545-9d11-09f1250a1c9b
7409b248-a723-48d5-b993-272de6b18346	fff848ab-d932-4226-b903-6dd676a157e9
7409b248-a723-48d5-b993-272de6b18346	badc51b5-2b17-40cf-9ddc-7f109efda359
7409b248-a723-48d5-b993-272de6b18346	13a75c7a-6e7d-41c9-89f6-562f21da2d95
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	792971c4-51df-4bf8-8c66-5f50c6831a81
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	dc2c93b5-7f2b-4e05-aa33-54630913f2ad
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	45370bb9-2583-4e09-9546-e1b8ce293eda
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	3de140eb-68c9-4545-9d11-09f1250a1c9b
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	12483c1a-d4bf-4da7-8899-04225bf4dcbb
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	c0ea566a-34e8-4789-a45b-d5fb7e62551c
c872a6bd-16ec-45fe-a64b-7f16b3cbd0bb	13a75c7a-6e7d-41c9-89f6-562f21da2d95
58b9fd50-9ae8-4f29-b61c-344218bc98f5	792971c4-51df-4bf8-8c66-5f50c6831a81
58b9fd50-9ae8-4f29-b61c-344218bc98f5	dc2c93b5-7f2b-4e05-aa33-54630913f2ad
58b9fd50-9ae8-4f29-b61c-344218bc98f5	45370bb9-2583-4e09-9546-e1b8ce293eda
58b9fd50-9ae8-4f29-b61c-344218bc98f5	3de140eb-68c9-4545-9d11-09f1250a1c9b
58b9fd50-9ae8-4f29-b61c-344218bc98f5	b2697197-0221-48d9-95bd-c8f6ce4ab8b5
58b9fd50-9ae8-4f29-b61c-344218bc98f5	c0ea566a-34e8-4789-a45b-d5fb7e62551c
58b9fd50-9ae8-4f29-b61c-344218bc98f5	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
bed7dd31-1676-4af4-9117-9efd1f0607d7	792971c4-51df-4bf8-8c66-5f50c6831a81
bed7dd31-1676-4af4-9117-9efd1f0607d7	45370bb9-2583-4e09-9546-e1b8ce293eda
bed7dd31-1676-4af4-9117-9efd1f0607d7	3de140eb-68c9-4545-9d11-09f1250a1c9b
bed7dd31-1676-4af4-9117-9efd1f0607d7	c0ea566a-34e8-4789-a45b-d5fb7e62551c
bed7dd31-1676-4af4-9117-9efd1f0607d7	13a75c7a-6e7d-41c9-89f6-562f21da2d95
1503796f-f108-4270-9fbe-7b1516c0a18d	792971c4-51df-4bf8-8c66-5f50c6831a81
1503796f-f108-4270-9fbe-7b1516c0a18d	45370bb9-2583-4e09-9546-e1b8ce293eda
1503796f-f108-4270-9fbe-7b1516c0a18d	3de140eb-68c9-4545-9d11-09f1250a1c9b
1503796f-f108-4270-9fbe-7b1516c0a18d	c0ea566a-34e8-4789-a45b-d5fb7e62551c
1503796f-f108-4270-9fbe-7b1516c0a18d	80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2
1503796f-f108-4270-9fbe-7b1516c0a18d	13a75c7a-6e7d-41c9-89f6-562f21da2d95
\.


--
-- Data for Name: tag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tag (id, type, name_ru, name_en, ctime, utime) FROM stdin;
49744a98-3830-4648-890e-f8fe87521d6a	category	fgghfghgf	fgghfghgf	2026-09-20 19:33:57.794519+00	\N
e2c98a8e-0c98-41d4-8ac2-83e3dcf0f564	111111	22222	22222	2026-09-20 19:33:57.794519+00	\N
1835bc6b-a8a1-4b40-85fa-a203dc47cf90	category	Завтрак	breakfast	2026-09-20 20:06:50.306+00	\N
f92f7430-6271-4050-a9dd-191c88d6c520	category	Обед	lunch	2026-09-20 20:06:50.317+00	\N
26c16040-656a-411d-a7f8-66160125d7f8	category	Ужин	dinner	2026-09-20 20:06:50.327+00	\N
35f9fc5d-f740-43c4-bc4e-f0a6b35dc892	category	Салат	salad	2026-09-20 20:06:50.336+00	\N
792971c4-51df-4bf8-8c66-5f50c6831a81	category	Перекус	snack	2026-09-20 20:06:50.344+00	\N
dc2c93b5-7f2b-4e05-aa33-54630913f2ad	meal_type	Завтрак	breakfast	2026-09-20 20:06:50.354+00	\N
d28ee3f6-4e0e-4cdb-b7d5-09048b1f91e8	meal_type	Поздний завтрак	brunch	2026-09-20 20:06:50.363+00	\N
2f97a990-b1b7-4716-9404-45f393ca3e97	meal_type	Обед	lunch	2026-09-20 20:06:50.372+00	\N
56c468ca-2f4f-415e-ba60-1fdcdce88c74	meal_type	Ужин	dinner	2026-09-20 20:06:50.382+00	\N
45370bb9-2583-4e09-9546-e1b8ce293eda	meal_type	Перекус	snack	2026-09-20 20:06:50.39+00	\N
3de140eb-68c9-4545-9d11-09f1250a1c9b	dietary	Вегетарианское	vegetarian	2026-09-20 20:06:50.398+00	\N
b2697197-0221-48d9-95bd-c8f6ce4ab8b5	dietary	Веганское	vegan	2026-09-20 20:06:50.406+00	\N
708e2a22-bc25-475f-94dc-30f8af0d48da	dietary	Пескетарианское	pescatarian	2026-09-20 20:06:50.413+00	\N
80aa765f-2a7c-42bf-9aaa-f5a2c31d2ed2	dietary	Без глютена	gluten-free	2026-09-20 20:06:50.421+00	\N
17676826-9ab2-47a0-b925-36867ffcb8cd	dietary	Низкоуглеводное	low-carb	2026-09-20 20:06:50.428+00	\N
12483c1a-d4bf-4da7-8899-04225bf4dcbb	dietary	Высокобелковое	high-protein	2026-09-20 20:06:50.437+00	\N
c0ea566a-34e8-4789-a45b-d5fb7e62551c	dietary	Быстро и просто	quick-easy	2026-09-20 20:06:50.446+00	\N
fff848ab-d932-4226-b903-6dd676a157e9	allergen	Глютен	gluten	2026-09-20 20:06:50.454+00	\N
13a75c7a-6e7d-41c9-89f6-562f21da2d95	allergen	Молочное	dairy	2026-09-20 20:06:50.46+00	\N
badc51b5-2b17-40cf-9ddc-7f109efda359	allergen	Яйцо	egg	2026-09-20 20:06:50.468+00	\N
ce6f90d7-fcc1-419d-a81d-c9f6705cd72f	allergen	Рыба	fish	2026-09-20 20:06:50.475+00	\N
f9091468-45e9-47cc-9762-74b2609edc08	allergen	Моллюски	shellfish	2026-09-20 20:06:50.483+00	\N
77b878e7-1631-4fff-b12a-03001d07ef4a	allergen	Орехи	tree nuts	2026-09-20 20:06:50.49+00	\N
30868e77-77e3-4d0e-8d5d-7533373c1c7f	allergen	Арахис	peanuts	2026-09-20 20:06:50.497+00	\N
e5312f1a-62cf-4588-b6d8-d8274f07c86f	allergen	Соя	soy	2026-09-20 20:06:50.504+00	\N
b0ce49d7-5fca-4864-a265-0d6368cdc105	allergen	Кунжут	sesame	2026-09-20 20:06:50.511+00	\N
\.


--
-- Name: dictionary_update dictionary_update_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dictionary_update
    ADD CONSTRAINT dictionary_update_pkey PRIMARY KEY (name);


--
-- Name: ingredient ingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredient
    ADD CONSTRAINT ingredient_pkey PRIMARY KEY (id);


--
-- Name: ingredient_tag ingredient_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredient_tag
    ADD CONSTRAINT ingredient_tag_pkey PRIMARY KEY (ingredient_id, tag_id);


--
-- Name: my_item my_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.my_item
    ADD CONSTRAINT my_item_pkey PRIMARY KEY (id);


--
-- Name: my_session my_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.my_session
    ADD CONSTRAINT my_session_pkey PRIMARY KEY (user_id, token);


--
-- Name: my_user my_user_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.my_user
    ADD CONSTRAINT my_user_email_key UNIQUE (email);


--
-- Name: my_user my_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.my_user
    ADD CONSTRAINT my_user_pkey PRIMARY KEY (id);


--
-- Name: recipe_ingredient recipe_ingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredient
    ADD CONSTRAINT recipe_ingredient_pkey PRIMARY KEY (recipe_id, ingredient_id);


--
-- Name: recipe recipe_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe
    ADD CONSTRAINT recipe_pkey PRIMARY KEY (id);


--
-- Name: recipe_tag recipe_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_tag
    ADD CONSTRAINT recipe_tag_pkey PRIMARY KEY (recipe_id, tag_id);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: tag tag_type_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_type_name_key UNIQUE (type, name_ru);


--
-- Name: ingredient_tag ingredient_tag_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredient_tag
    ADD CONSTRAINT ingredient_tag_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient(id);


--
-- Name: ingredient_tag ingredient_tag_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredient_tag
    ADD CONSTRAINT ingredient_tag_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id);


--
-- Name: my_item my_item_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.my_item
    ADD CONSTRAINT my_item_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.my_user(id);


--
-- Name: my_session my_session_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.my_session
    ADD CONSTRAINT my_session_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.my_user(id);


--
-- Name: recipe_ingredient recipe_ingredient_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredient
    ADD CONSTRAINT recipe_ingredient_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient(id);


--
-- Name: recipe_ingredient recipe_ingredient_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredient
    ADD CONSTRAINT recipe_ingredient_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipe(id);


--
-- Name: recipe_tag recipe_tag_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_tag
    ADD CONSTRAINT recipe_tag_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipe(id);


--
-- Name: recipe_tag recipe_tag_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_tag
    ADD CONSTRAINT recipe_tag_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id);


--
-- PostgreSQL database dump complete
--

\unrestrict LiDzoYecFrVHul3RdHmc4iYFzWJuouosAm1AG1cSL5NFkma8daBgtSaNcOO0l2S

