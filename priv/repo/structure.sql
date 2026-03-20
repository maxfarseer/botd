--
-- PostgreSQL database dump
--

\restrict brvQ4OfuJV0nwt89H8wxTxmBErZZCLrd8bLFpEGZZq6oGgxcWHKNxTbgrsMFLed

-- Dumped from database version 14.22 (Homebrew)
-- Dumped by pg_dump version 14.22 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: activity_logs_action_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.activity_logs_action_type AS ENUM (
    'create_person',
    'create_person_via_suggestion',
    'edit_person',
    'remove_person',
    'create_suggestion',
    'edit_suggestion',
    'remove_suggestion',
    'approve_suggestion',
    'reject_suggestion'
);


--
-- Name: activity_logs_entity_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.activity_logs_entity_type AS ENUM (
    'person',
    'suggestion'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'moderator',
    'member'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_logs (
    id bigint NOT NULL,
    entity_id integer NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    entity_type public.activity_logs_entity_type NOT NULL,
    action public.activity_logs_action_type NOT NULL,
    user_id bigint
);


--
-- Name: activity_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_logs_id_seq OWNED BY public.activity_logs.id;


--
-- Name: old_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.old_users (
    id bigint NOT NULL,
    email character varying(255),
    password_hash character varying(255),
    inserted_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    role character varying(255) DEFAULT 'member'::character varying
);


--
-- Name: old_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.old_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: old_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.old_users_id_seq OWNED BY public.old_users.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people (
    id bigint NOT NULL,
    name character varying NOT NULL COLLATE pg_catalog."und-x-icu",
    nickname character varying COLLATE pg_catalog."und-x-icu",
    birth_date date,
    death_date date NOT NULL,
    place character varying COLLATE pg_catalog."und-x-icu",
    cause_of_death text,
    description character varying COLLATE pg_catalog."und-x-icu",
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    photo_url character varying(255)
);


--
-- Name: persons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.persons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: persons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.persons_id_seq OWNED BY public.people.id;


--
-- Name: photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.photos (
    id bigint NOT NULL,
    url character varying(255) NOT NULL,
    size character varying(255) NOT NULL,
    person_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.photos_id_seq OWNED BY public.photos.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suggestions (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    death_date date NOT NULL,
    place character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    notes text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    user_id bigint,
    reviewed_by_id bigint,
    telegram_username character varying(255),
    photo_url character varying(255),
    photos character varying(255)[]
);


--
-- Name: suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suggestions_id_seq OWNED BY public.suggestions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    hashed_password character varying(255) NOT NULL,
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    role character varying(255) DEFAULT 'member'::character varying NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_tokens_id_seq OWNED BY public.users_tokens.id;


--
-- Name: activity_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_logs ALTER COLUMN id SET DEFAULT nextval('public.activity_logs_id_seq'::regclass);


--
-- Name: old_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.old_users ALTER COLUMN id SET DEFAULT nextval('public.old_users_id_seq'::regclass);


--
-- Name: people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people ALTER COLUMN id SET DEFAULT nextval('public.persons_id_seq'::regclass);


--
-- Name: photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos ALTER COLUMN id SET DEFAULT nextval('public.photos_id_seq'::regclass);


--
-- Name: suggestions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggestions ALTER COLUMN id SET DEFAULT nextval('public.suggestions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (id);


--
-- Name: old_users old_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.old_users
    ADD CONSTRAINT old_users_pkey PRIMARY KEY (id);


--
-- Name: people persons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT persons_pkey PRIMARY KEY (id);


--
-- Name: photos photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: suggestions suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggestions
    ADD CONSTRAINT suggestions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: activity_logs_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_logs_user_id_index ON public.activity_logs USING btree (user_id);


--
-- Name: people_name_death_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX people_name_death_date_index ON public.people USING btree (name, death_date);


--
-- Name: persons_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX persons_name_index ON public.people USING btree (name);


--
-- Name: photos_person_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX photos_person_id_index ON public.photos USING btree (person_id);


--
-- Name: suggestions_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX suggestions_status_index ON public.suggestions USING btree (status);


--
-- Name: suggestions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX suggestions_user_id_index ON public.suggestions USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_role_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_role_index ON public.users USING btree (role);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: activity_logs activity_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: photos photos_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.people(id) ON DELETE CASCADE;


--
-- Name: suggestions suggestions_reviewed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggestions
    ADD CONSTRAINT suggestions_reviewed_by_id_fkey FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: suggestions suggestions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggestions
    ADD CONSTRAINT suggestions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict brvQ4OfuJV0nwt89H8wxTxmBErZZCLrd8bLFpEGZZq6oGgxcWHKNxTbgrsMFLed

INSERT INTO public."schema_migrations" (version) VALUES (20250409142556);
INSERT INTO public."schema_migrations" (version) VALUES (20250409144508);
INSERT INTO public."schema_migrations" (version) VALUES (20250409191424);
INSERT INTO public."schema_migrations" (version) VALUES (20250411063955);
INSERT INTO public."schema_migrations" (version) VALUES (20250412142352);
INSERT INTO public."schema_migrations" (version) VALUES (20250413181916);
INSERT INTO public."schema_migrations" (version) VALUES (20250415154139);
INSERT INTO public."schema_migrations" (version) VALUES (20250417133145);
INSERT INTO public."schema_migrations" (version) VALUES (20250418102607);
INSERT INTO public."schema_migrations" (version) VALUES (20250418102610);
INSERT INTO public."schema_migrations" (version) VALUES (20250418124719);
INSERT INTO public."schema_migrations" (version) VALUES (20250422160230);
INSERT INTO public."schema_migrations" (version) VALUES (20250422160529);
INSERT INTO public."schema_migrations" (version) VALUES (20250423084034);
INSERT INTO public."schema_migrations" (version) VALUES (20250425101032);
INSERT INTO public."schema_migrations" (version) VALUES (20250430074815);
INSERT INTO public."schema_migrations" (version) VALUES (20250430085099);
INSERT INTO public."schema_migrations" (version) VALUES (20250430085100);
INSERT INTO public."schema_migrations" (version) VALUES (20250430085149);
INSERT INTO public."schema_migrations" (version) VALUES (20250430102939);
INSERT INTO public."schema_migrations" (version) VALUES (20250430105049);
INSERT INTO public."schema_migrations" (version) VALUES (20250430105357);
INSERT INTO public."schema_migrations" (version) VALUES (20250514134902);
INSERT INTO public."schema_migrations" (version) VALUES (20250514150128);
INSERT INTO public."schema_migrations" (version) VALUES (20250523130139);
INSERT INTO public."schema_migrations" (version) VALUES (20250527145737);
INSERT INTO public."schema_migrations" (version) VALUES (20250529182322);
