--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.6
-- Dumped by pg_dump version 9.5.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

ALTER TABLE IF EXISTS ONLY public.fines DROP CONSTRAINT IF EXISTS fines_patron_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fines DROP CONSTRAINT IF EXISTS fines_book_id_fkey;
ALTER TABLE IF EXISTS ONLY public.books DROP CONSTRAINT IF EXISTS books_publisher_id_fkey;
ALTER TABLE IF EXISTS ONLY public.books DROP CONSTRAINT IF EXISTS books_collection_id_fkey;
ALTER TABLE IF EXISTS ONLY public.books DROP CONSTRAINT IF EXISTS books_checked_out_by_fkey;
ALTER TABLE IF EXISTS ONLY public.book_subjects DROP CONSTRAINT IF EXISTS book_subjects_subject_id_fkey;
ALTER TABLE IF EXISTS ONLY public.book_subjects DROP CONSTRAINT IF EXISTS book_subjects_book_id_fkey;
ALTER TABLE IF EXISTS ONLY public.book_authors DROP CONSTRAINT IF EXISTS book_authors_book_id_fkey;
ALTER TABLE IF EXISTS ONLY public.book_authors DROP CONSTRAINT IF EXISTS book_authors_author_id_fkey;
DROP INDEX IF EXISTS public.fines_patron_id_book_id_date_idx;
ALTER TABLE IF EXISTS ONLY public.subjects DROP CONSTRAINT IF EXISTS subjects_pkey;
ALTER TABLE IF EXISTS ONLY public.subjects DROP CONSTRAINT IF EXISTS subjects_name_key;
ALTER TABLE IF EXISTS ONLY public.publishers DROP CONSTRAINT IF EXISTS publishers_pkey;
ALTER TABLE IF EXISTS ONLY public.publishers DROP CONSTRAINT IF EXISTS publishers_name_key;
ALTER TABLE IF EXISTS ONLY public.patrons DROP CONSTRAINT IF EXISTS patrons_pkey;
ALTER TABLE IF EXISTS ONLY public.patrons DROP CONSTRAINT IF EXISTS patrons_email_key;
ALTER TABLE IF EXISTS ONLY public.fines DROP CONSTRAINT IF EXISTS fines_pkey;
ALTER TABLE IF EXISTS ONLY public.collections DROP CONSTRAINT IF EXISTS collections_pkey;
ALTER TABLE IF EXISTS ONLY public.collections DROP CONSTRAINT IF EXISTS collections_name_key;
ALTER TABLE IF EXISTS ONLY public.books DROP CONSTRAINT IF EXISTS books_pkey;
ALTER TABLE IF EXISTS ONLY public.book_subjects DROP CONSTRAINT IF EXISTS book_subjects_pkey;
ALTER TABLE IF EXISTS ONLY public.book_authors DROP CONSTRAINT IF EXISTS book_authors_pkey;
ALTER TABLE IF EXISTS ONLY public.authors DROP CONSTRAINT IF EXISTS authors_pkey;
ALTER TABLE IF EXISTS ONLY public.authors DROP CONSTRAINT IF EXISTS authors_name_key;
ALTER TABLE IF EXISTS public.subjects ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.publishers ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.patrons ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.fines ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.books ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.authors ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.subjects_id_seq;
DROP SEQUENCE IF EXISTS public.publishers_id_seq;
DROP TABLE IF EXISTS public.publishers;
DROP SEQUENCE IF EXISTS public.patrons_id_seq;
DROP VIEW IF EXISTS public.overdue_books;
DROP SEQUENCE IF EXISTS public.fines_id_seq;
DROP TABLE IF EXISTS public.fines;
DROP VIEW IF EXISTS public.checked_out_books;
DROP TABLE IF EXISTS public.patrons;
DROP TABLE IF EXISTS public.collections;
DROP SEQUENCE IF EXISTS public.books_id_seq;
DROP VIEW IF EXISTS public.book_fulltext;
DROP TABLE IF EXISTS public.subjects;
DROP TABLE IF EXISTS public.books;
DROP TABLE IF EXISTS public.book_subjects;
DROP TABLE IF EXISTS public.book_authors;
DROP SEQUENCE IF EXISTS public.authors_id_seq;
DROP TABLE IF EXISTS public.authors;
DROP EXTENSION IF EXISTS plpgsql;
DROP SCHEMA IF EXISTS public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authors (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authors_id_seq OWNED BY authors.id;


--
-- Name: book_authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE book_authors (
    book_id integer NOT NULL,
    author_id integer NOT NULL
);


--
-- Name: book_subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE book_subjects (
    book_id integer NOT NULL,
    subject_id integer NOT NULL
);


--
-- Name: books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE books (
    id integer NOT NULL,
    isbn character varying(13) NOT NULL,
    title character varying(500) NOT NULL,
    year_published integer NOT NULL,
    dewey_decimal numeric(6,3),
    lcc_number character varying(20),
    available_for_check_out boolean DEFAULT true NOT NULL,
    checked_out_at timestamp without time zone,
    collection_id integer,
    publisher_id integer,
    checked_out_by integer
);


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE subjects (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: book_fulltext; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW book_fulltext AS
 SELECT b.id,
    b.title,
    to_tsvector((((b.title)::text || ' '::text) || string_agg(replace((s.name)::text, '_'::text, ' '::text), ' '::text))) AS fulltext
   FROM ((subjects s
     JOIN book_subjects bs ON ((s.id = bs.subject_id)))
     JOIN books b ON ((bs.book_id = b.id)))
  GROUP BY b.id, b.title;


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE books_id_seq OWNED BY books.id;


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE collections (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    checkout_duration interval day NOT NULL,
    fine_per_day money
);


--
-- Name: patrons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE patrons (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL
);


--
-- Name: checked_out_books; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW checked_out_books AS
 SELECT b.id AS book_id,
    b.title AS book_title,
    p.id AS patron_id,
    p.name AS patron_name,
    (date_trunc('day'::text, (b.checked_out_at + c.checkout_duration)))::date AS due_date
   FROM ((books b
     JOIN patrons p ON ((b.checked_out_by = p.id)))
     JOIN collections c ON ((b.collection_id = c.id)));


--
-- Name: fines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fines (
    id integer NOT NULL,
    patron_id integer NOT NULL,
    book_id integer NOT NULL,
    date date,
    amount money
);


--
-- Name: fines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fines_id_seq OWNED BY fines.id;


--
-- Name: overdue_books; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW overdue_books AS
 SELECT checked_out_books.book_id,
    checked_out_books.book_title,
    checked_out_books.patron_id,
    checked_out_books.patron_name,
    checked_out_books.due_date,
    (('now'::text)::date - checked_out_books.due_date) AS days_overdue
   FROM checked_out_books
  WHERE (checked_out_books.due_date < ('now'::text)::date);


--
-- Name: patrons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE patrons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patrons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE patrons_id_seq OWNED BY patrons.id;


--
-- Name: publishers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE publishers (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: publishers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE publishers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publishers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE publishers_id_seq OWNED BY publishers.id;


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subjects_id_seq OWNED BY subjects.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authors ALTER COLUMN id SET DEFAULT nextval('authors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY books ALTER COLUMN id SET DEFAULT nextval('books_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fines ALTER COLUMN id SET DEFAULT nextval('fines_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY patrons ALTER COLUMN id SET DEFAULT nextval('patrons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY publishers ALTER COLUMN id SET DEFAULT nextval('publishers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subjects ALTER COLUMN id SET DEFAULT nextval('subjects_id_seq'::regclass);


--
-- Data for Name: authors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY authors (id, name) FROM stdin;
1	Mears, Henrietta C.
2	Singer, Judith D.
3	Ray Chambers
4	Govier, Katherine
5	Mack, Karin
6	McCullagh, Peter
7	Silver, Denise
8	Lemeshow, Stanley
9	Lester, Alison
10	Anthony, Piers
11	Sexton, Anne
12	Cook, Glen
13	Leah A. Crussell
14	Koontz, Dean R.
15	Deutcsh, Arthur V.
16	Wilhelm, Kate
17	Beauman, Sally
18	Chalker, Jack L.
19	Freund, Rudolf
20	Kopp, Nancy
21	Binchy, Maeve
22	Rockwell, F. F.
23	Smyth, Jolene D.
24	Bretton, Barbara
25	Stamp, Terence
26	Time-Life Books
27	Racine, Bernard
28	White, Stephen
29	Kinnear, Paul R
30	Simmons, Leo W.
31	Carleen Glasser
32	Yellin, Frank
33	Spinelli, Jerry
34	Penycate, John
35	Susea McGearhart
36	Meyer, Verne
37	Larson, Mark L.
38	Singh, Ravindra
39	Cooper, Jeff
40	Erica Spindler
41	Griffith, H. Winter
42	Coulter, Ann H.
43	Presser, Stanley
44	Rosenstock, Janet
45	Lescroart, John T.
46	Grass, Gnter
47	Ripley, Brian D.
48	William Edwards Deming
49	Leigh, Allison
50	Vitkus, John
51	Schwager, Jack D.
52	Gauvreau, Kimberlee
53	Fox, John
54	Sheree Petree
55	Chambers, R. L. Skinner, C. J.
56	Christian, Leah Melani
57	Williams, Chuck
58	Singer, Eleanor
59	Yoshikawa, Mako
60	N/A
61	Oakland, John S.
62	Atwood, Margaret Eleanor
63	Couper, Mick
64	Baird, Jonathan
65	Jennifer M. Rothgeb
66	Georges Perec
67	Neter, John
68	Riccio, Dolores
69	Bulman-Fleming, Andy
70	Shayle R. Searle
71	Sowerby, Robin
72	McGarvey, Patrick J.
73	Conrad, Joseph
74	Chesnutt, Charles Waddell
75	Graybill, Franklin A.
76	Honeycutt, Jerry
77	Solomon, David A.
78	Romano, Joseph P.
79	Ash, Carol
80	Lester, Helen
81	Jacques, Brian
82	Sullivan, William
83	Hamada, Michael
84	Moon, Susan Ichi Su
85	Abramson, Paul R.
86	Cunningham, Jere
87	Lee, Vic
88	Christa Roberts
89	Kouhoupt And Marti
90	Dennis, Lane T.
91	Lee, Eun Sul
92	Cornwell, Patricia Daniels
93	Farris, John
94	Carbeck, Hank
95	Greenfield, Eloise
96	Forthofer, Ron N.
97	Flynn, Christine
98	Smith, Jeffrey K.
99	Hersey, John
100	Israeloff, Roberta
101	Addis, Faith
102	Walter W. Stroup
103	Dietz, Marjorie J.
104	Dean Ornish MD
105	Davison, A. N.
106	Cloud, Henry
107	Kahn, Michael D.
108	Fielding, Joy
109	Patricia A. Berglund
110	Schaeffer, Francis A.
111	Balena, Francesco
112	Sabato
113	PhD. Eric Skjei
114	Kerry Milliron
115	Kempe, Margery
116	Eggleton, Bob
117	Ladd-Taylor, Molly
118	Rand, Ayn
119	Klaassen, Walter
120	Clamp
121	Sexton, A. Jeanette
122	Voss, Daniel
123	McKnight, Jenna
124	Martin, Jean
125	Henderson, Don L.
126	Hastie, Trevor
127	Dunne, Dominick
128	Jaffe, Michele
129	Cox, Patricia
130	Susan Manlin Katzman
131	Carpenter, James M.
132	Weems, Chip
133	Grimm, Laurence G.
134	Milton, J. Susan
135	Lehtonen, Risto
136	Bowen, Judith
137	Heggan, Christiane
138	Kilgour, David
139	Glemser, Bernard
140	Lansing, John Stephen
141	Wood, John Maxwell
142	Williams, Larry R.
143	Robbins, John
144	King, Francis
145	Sparrow, Thomas
146	Alcott, Louisa M.
147	Woodrell, Daniel
148	Anderson, Daniel R.
149	Quick, Amanda
150	Bradley, Marion Zimmer
151	Veninga, Robert L.
152	Skjei, Eric W.
153	Turtledove, Harry
154	Camp, Kim
155	S. Andrew Swann
156	Seymour, Gerald
157	Sincich, Terry
158	Brady, James E.
159	Kegan, Stephanie
160	Green, Roger Curtis
161	Hinkelmann, Klaus
162	Inglehart, Ronald
163	Robert, Michel
164	Koestler, Arthur
165	Pablo Marcos Studio
166	Wallnau, Larry B.
167	Hickey, Leo
168	Townsend, John Rowe
169	Mayer, Mercer
170	Gage, John D.
171	Headington, Mark R.
172	Jones, Frank C.
173	Carey, Diane
174	Danesh, Arman
175	Pedro de Cieza de Le�n
176	Suzanne, Jamie
177	Wichern, Dean W.
178	Kemper, Dave
179	Grafton, Sue
180	Dale, Nell B.
181	Dunmore, Helen
182	Laiken, Deidre S.
183	Allen, Woody
184	Michener, James A.
185	Martin, Elizabeth
186	Dole, Robert J.
187	Morgan, James C.
188	G. Bruce Schaalje
189	Meyers, Manny
190	Henley, Virginia
191	Robards, Karen
192	Dean, Angela
193	Crosbie, Lynn
194	Ljiljana Baird
195	Allen, Carol
196	Julian J. Faraway
197	Cody, Ronald P.
198	Eckhard Weise
199	Rutherford, Andrew
200	Gilman, Dorothy
201	Hayes, Sarah
202	Kuntzleman, Charles T.
203	Claverie, Jean-Michel
204	McMillan, Michael
205	Sperling, Dave
206	Patricia Unterman
207	Jrgen Habermas
208	Gilbert, Michael Francis
209	Trevor-Roper, Hugh Redwald
210	Clow, Barbara Hand
211	Terenci Moix
212	Fiorentino, Al
213	Wynne-Jones, Tim
214	Drucker, Daniel C.
215	Wretman, Jan H?kan
216	Lowry M
217	Fellows, Will
218	Fleischman, Paul
219	Walker, Jonathan
220	Kenward, Michael
221	Tucker, Sian
222	Craig, Helen
223	Cay Van Ash
224	Hart, Johnny
225	Michael Cane
226	S�rndal, Carl-Erik
227	Leclaire, Day
228	Gilbert, Harry
229	Gilliam, Richard
230	Heinlein, Robert A.
231	Higson, Charles
232	Lee, Harper
233	Nelder, John A.
234	Klein, John
235	Palmer, Joan
236	Muskhelishvili, N. I.
237	Christie, Agatha
238	Peters, Ellis
239	Boyd, Margaret Ann
240	Foxall, James D.
241	Gray, Henry David
242	Bennett W. McEwan
243	Musciano, Chuck
244	Gill, Anton
245	Hassler, Jon
246	Sowell, Thomas
247	Leibold, Jay
248	Smith, Harry
249	Williams, Kenneth S.
250	Feehan, Christine
251	Pahkinen, Erkki
252	DeLillo, Don
253	Hailsham of St Marylebone, Quintin Hogg
254	Aaron, Jane
255	McGarry, Molly
256	Gravetter, Frederick J.
257	Chaudhuri, Arijit
258	Stewart, James B.
259	L�vy, Azriel
260	Page, Scott E.
261	Pagano, Marcello
262	Art Ginsburg
263	Moeschberger, Melvin L.
264	Campbell, Angus
265	Mangold, Tom
266	Andrews, George E.
267	Murphy, Kevin R.
268	Farrell, Christopher A.
269	Thompson, Steven K.
270	Lohr, Sharon L.
271	Friedman, Jerome
272	Willan, Anne
273	Willett, John
274	Gilchrist, Jan Spivey
275	Morressy, John
276	Lavrakas, Paul
277	Levy, Paul
278	Munsinger, Lynn
279	Scheaffer, Richard L.
280	Warner, Gertrude Chandler
281	Gabaldon, Diana
282	Groves, Robert M.
283	Milligan, Spike
284	Verbeke, Geert
285	Kempthorne, Oscar
286	Davies, Russell
287	Talayesva, Don C.
288	Brady West
289	Sebranek, Patrick
290	Maxwell, William
291	Baker, Chris
292	Sharp, Chris
293	Gray, Colin S.
294	Rosten, Leo Calvin
295	Holland, Paul W.
296	Hinkley, D. V.
297	Higgins, James
298	Molenberghs, Geert
299	Draper, Norman Richard
300	Traugott, Michael W.
301	Groening, Matt
302	Nowell-Smith, Geoffrey
303	Chong, Dennis
304	James Axler
305	Barnett, Vic
306	White, Bailey
307	Sarah
308	Morris, Max
309	Toni Turner
310	Staley, Lynn
311	Jordan, Robert S.
312	Montgomery, Douglas C.
313	Foy, George
314	McCulloch, Charles E.
315	Joanna David
316	Krewski, D.
317	Pascal, Francine
318	Twain, Mark
319	Watson, Peter
320	Cabrera, Javier
321	Gunning, Sandra
322	Miller, John H.
323	Roberson, Jennifer
324	Fogiel, Max
325	Kennedy, Bill
326	Myers, Raymond H.
327	Clark, Robert A.
328	Silber, Diana
329	Lessler, Judith
330	Oluf Zierl
331	John Paul
332	Miller, William C.
333	Gosling, James
334	H.G. WELLS
335	Mike Schneider
336	Abel Matias
337	Steinbeck, John
338	Craig, Eleanor
339	Mukhopadhyay, Parimal
340	Lord, Bette
341	Agresti, Alan
342	Soto, Gary
343	Colson, Charles W.
344	Tapie, Jean-Paul
345	Law, Susan Kay
346	Huth, Angela
347	Pope, Alexander
348	Brian Cochran
349	Govindarajulu, Z.
350	M. William Phelps
351	Klots, Alexander Barrett
352	Vipperman, Carol
353	Glasser, William
354	Thurman, Robert A. F.
355	Joss, Morag
356	Fienberg, Stephen E.
357	Singh Mangat, Naurang
358	Auchincloss, Louis
359	Griffis, Michael
360	Hochman, Gloria
361	Golden Books
362	Gentle, James E.
363	Kennedy, X. J.
364	Lamott, Anne
365	Furlong, Monica
366	Timm, Neil H.
367	Aaron Percifull
368	Chris Shorten
369	David McGlothlin
370	Boltz, Ray
371	Grace, Fran
372	Tanter, Raymond
373	Lundstr�m, Sixten
374	Josh DiPietro
375	Dillman, Don A.
376	Neuhaus, John William
377	Marcus, Eric
378	Salter, Anna C.
379	Calvin Skaggs
380	Davis, John F.
381	Crutcher, Chris
382	Mendenhall, William
383	Anderson, Kevin J.
384	Saint-Exupery, Antoine de
385	Lisa Bingham
386	Erika Dillman
387	PhD. Maureen D. Mack
388	George, John
389	Kennedy, Dorothy M.
390	Woodhouse, Barbara
391	Taylor, Richard
392	Nafisi, Azar
393	Dharathula H. Millender
394	David Collett
395	Killough, Lee
396	Fuller, Wayne Edison
397	Johnson, Dallas E.
398	Sobell, Mark G.
399	Ronald J. Lorimor
400	Maggie Groening
401	Lv?y, Azriel
402	McDougall, Andrew
403	Shillinglaw, Susan
404	Say, Allen
405	Coulter, Catherine
406	Hiaasen, Carl
407	Tibshirani, Robert
408	Tidwell, Doug
409	Nison, Steve
410	Ann Llewellyn Evans
411	Justice, William G.
412	Holloway, Harry
413	Waldman, Ayelet
414	Paul, Raymond
415	Epstein, Lita
416	Joan Lewis
417	Skiena, Steven S.
418	DeChancie, John
419	Lay, David C.
420	Land, Jon
421	Tang, Charles
422	Kim, Sung Bok
423	Littell, Ramon C.
424	Anne Androff
425	Laura Brooks
426	Pagel, Stephen
427	Cassel, Claes
428	Crow, Donna Fletcher
429	Reynolds, Blair
430	Whitehead, Paul C.
431	Johnson, Richard R.
432	Singer, Isaac Bashevis
433	Snyder, Dianne
434	Hair, Joseph F.
435	Tourangeau, Roger
436	Greenberg, Martin Harry
437	Lashner, William
438	Barraclough, Geoffrey
439	Louv, Richard
440	Pick, T. Pickering
441	Otto Bretscher
442	Wolter, Kirk M.
443	Musser, Joe
444	Johansen, Iris
445	Bishop, Yvonne M. M.
446	Mark Owen
447	Blaiklock, E. M.
448	Goldberg, Samuel I.
449	RICHARD ALLEMAN
450	BILL MONTALBANO
451	Tami Oldham Ashcraft
452	Lavall?ee, Pierre
453	Paxson, Diana L.
454	Frederick G. Conrad
455	MacLean, Alistair
456	McCullagh, P.
457	Higham, Charles
458	Wills, Maury
459	Kramer, Edward E.
460	Smith, Dean
461	Sarjinder Singh
462	William Nagler
463	Huisman, Philippe
464	Gronau, Mary Ellen
465	Asimov, Isaac
466	Celizic, Mike
467	Isaacs, Larry D.
468	Crawley, Michael J.
469	Platek, Richard
470	Seger, Maura
471	Cartland, Barbara
472	Ott, Lyman
473	Bentley, Nancy
474	Howden, Robert
475	Yarsinske, Amy Waters
476	Shannon Hollis
477	Philip C. Spector
478	Briskin, Jacqueline
479	Wagner, Richard
480	Vavra, Robert
481	Mortimer, Carole
482	Kuehl, R. O.
483	Lundstr?om, Sixten
484	Art Lindsley
485	Middleton-Sandford, Betty
486	Grafton
487	Lavender, Gwyn
488	Max Haines
489	Duke, Patty
490	Marks, Leo
491	Lumley, Brian
492	Derek Melber
493	Notredame, Cedric
494	Asman, Mark F.
495	Thompson, Julian F.
496	Woodward, Mark R.
497	Stacy, Lori
498	Sarton, May
499	Rinker, Harry L.
500	Dortu, M. G.
501	Delibes, Miguel
502	S?arndal, Carl-Erik
503	Wood, Jane
504	Janet Mendel
505	Dickens, Charles
506	Wasserman, Fred
507	Rao, J. S.
508	Adair, Dennis
509	Taylor, Rick J.
510	Ronald N. Forthofer
511	Rencher, Alvin C.
512	Mauk, David
513	Soos, Troy
514	Warren, Pat
515	Pearcey, Nancy
516	Fawkes, L. T.
517	Canty, A. J.
518	Tierney, Tom
519	Heeringa, Steven
520	Frank, Barbara E.
521	Nancy Madore
522	Romo, Ito
523	Thomas, Lowell
524	Hoffman, Alice
525	Yarnold, Paul R.
\.


--
-- Name: authors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('authors_id_seq', 525, true);


--
-- Data for Name: book_authors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY book_authors (book_id, author_id) FROM stdin;
1	309
2	128
3	309
4	326
4	134
5	398
6	382
6	157
7	461
8	341
9	3
9	327
10	297
11	55
12	91
12	510
12	399
12	96
13	67
14	2
14	273
15	366
16	397
17	431
17	177
18	431
18	177
19	299
19	248
20	53
21	197
21	98
22	519
22	288
22	109
23	401
23	259
24	203
24	493
25	105
25	296
25	517
26	125
27	417
28	258
28	520
28	69
28	148
28	214
29	341
30	72
31	303
32	322
32	260
33	316
33	469
33	507
34	142
35	268
36	192
36	122
37	161
37	285
38	312
39	308
40	482
41	63
42	445
42	356
42	295
43	140
43	187
44	279
44	382
44	472
45	279
45	382
45	472
46	349
47	38
47	357
48	496
49	226
49	373
49	502
49	483
50	83
51	427
51	226
51	215
52	6
52	233
52	456
53	314
53	70
53	376
54	51
55	39
56	243
56	325
57	29
57	293
58	452
59	246
60	375
60	23
60	56
61	199
62	448
63	442
64	409
65	430
66	503
66	7
67	172
68	419
69	419
70	441
71	284
71	298
72	511
72	188
73	196
74	75
75	70
76	43
76	65
76	63
76	329
76	185
76	124
76	58
77	511
78	394
79	131
79	220
80	434
81	446
82	266
83	135
83	251
84	261
84	52
85	180
85	132
85	171
86	180
86	204
86	132
86	171
87	111
88	412
88	388
89	362
90	133
90	525
91	372
92	305
93	269
94	270
95	277
95	8
96	332
97	277
97	8
98	277
98	8
99	396
100	240
101	60
135	85
135	162
102	423
102	102
102	19
103	60
104	423
104	19
104	477
105	309
106	236
107	42
108	507
109	48
110	320
110	402
111	256
111	166
112	47
113	419
114	282
115	234
115	263
116	174
117	242
117	77
118	107
119	78
120	264
121	363
121	389
121	254
122	126
122	407
122	271
123	333
123	32
124	79
125	468
126	435
126	454
126	63
127	324
128	374
129	276
129	300
130	339
131	37
132	359
132	415
133	42
134	257
223	181
136	76
137	289
137	36
137	178
138	408
139	479
140	364
141	136
142	311
143	175
144	392
145	406
145	450
146	334
147	143
147	104
148	101
149	521
150	245
151	317
151	176
152	280
152	421
153	120
154	524
155	328
156	118
157	64
157	195
158	444
159	410
160	21
161	45
162	127
163	433
163	404
164	447
165	216
166	449
167	489
167	360
168	223
169	137
170	351
171	265
171	34
172	413
173	68
174	350
175	361
176	317
177	108
178	470
179	252
180	306
181	147
182	512
182	61
183	348
183	494
184	123
185	457
186	80
186	278
187	330
188	66
189	486
190	379
191	481
192	420
193	24
194	228
195	499
196	302
197	377
198	411
199	153
200	335
201	385
202	10
203	241
203	440
203	474
204	86
205	156
206	294
207	250
208	344
209	343
209	515
210	150
210	453
210	281
210	229
210	436
210	459
211	475
212	381
213	336
214	66
215	462
215	424
216	227
217	87
218	237
219	478
220	211
221	238
222	217
224	169
225	244
226	490
227	237
228	491
229	210
230	460
230	173
231	463
231	500
232	201
232	222
233	25
234	110
234	90
235	231
236	73
237	200
238	370
239	49
240	498
241	345
242	476
243	179
244	74
244	473
244	321
245	40
246	144
247	384
248	190
249	232
250	186
251	82
252	253
253	304
254	224
255	183
256	225
257	416
258	13
259	59
260	41
261	208
262	16
263	158
264	14
265	522
266	367
267	513
268	516
269	92
270	54
271	20
272	198
273	26
273	57
273	368
273	130
274	393
274	212
275	323
276	218
277	380
278	307
279	378
280	422
281	425
282	342
283	437
284	18
284	116
285	50
286	97
287	189
288	163
288	27
289	255
289	506
290	138
291	4
292	354
293	395
293	267
293	426
294	352
295	505
296	170
297	464
298	501
298	167
299	112
300	319
301	390
302	184
302	480
303	455
304	88
305	471
306	471
307	488
308	221
309	94
309	492
309	509
309	391
310	213
311	428
312	484
313	249
313	286
314	347
314	71
315	365
316	247
317	487
318	194
319	429
320	465
321	386
322	353
322	31
323	340
324	451
324	35
325	95
325	274
326	287
326	30
327	106
327	168
328	154
329	191
330	93
331	438
332	313
333	414
334	205
335	290
336	518
337	337
337	403
338	151
339	508
339	44
340	81
340	291
340	219
341	355
342	458
342	466
343	207
344	160
344	485
345	9
346	230
347	275
348	272
349	523
350	209
351	119
352	504
352	141
353	1
354	121
354	11
355	155
356	202
357	206
358	33
359	331
360	99
361	235
362	17
363	371
364	497
365	239
366	149
367	443
368	46
369	117
370	338
371	495
372	145
373	346
374	514
374	129
375	439
376	400
376	301
377	114
378	405
379	318
379	182
379	165
380	262
381	115
381	310
382	146
383	100
384	164
385	418
386	139
387	12
388	89
389	159
390	103
390	22
391	28
391	292
391	369
392	15
393	467
394	193
395	176
395	317
396	358
397	432
398	84
399	387
399	113
399	5
399	152
400	383
401	283
402	62
402	315
\.


--
-- Data for Name: book_subjects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY book_subjects (book_id, subject_id) FROM stdin;
190	651
193	73
193	716
193	653
196	499
196	273
196	205
196	109
196	690
196	696
198	372
198	480
202	77
202	682
202	555
202	383
202	694
202	251
202	475
203	429
203	391
206	79
206	363
206	423
207	226
207	653
209	29
209	486
209	263
209	234
211	127
211	67
211	519
215	58
215	513
219	599
219	113
219	46
219	679
219	624
221	388
221	112
221	538
221	725
224	736
224	717
224	559
225	47
225	94
225	646
226	481
226	180
226	412
226	489
226	153
273	504
273	469
273	179
273	534
273	239
232	358
233	224
236	424
236	516
236	101
236	254
236	304
236	210
236	593
236	549
236	574
238	563
238	156
238	399
239	716
239	653
240	611
240	242
298	699
298	131
80	541
59	170
59	570
59	605
3	351
3	366
3	558
3	692
4	610
6	326
7	525
7	453
7	144
7	248
7	374
10	255
11	724
11	296
11	395
11	12
11	132
11	171
11	218
12	608
12	535
12	352
12	666
12	377
13	93
13	704
13	256
13	610
14	408
14	48
15	208
17	208
17	337
18	208
18	482
19	93
60	707
60	460
60	371
60	477
60	390
60	270
60	437
62	539
62	649
62	521
62	546
63	704
63	638
64	138
64	306
64	705
66	514
68	309
69	326
70	735
70	309
70	54
99	525
99	248
99	374
99	377
99	638
99	59
101	76
101	188
101	492
135	544
135	434
135	709
105	280
105	312
105	306
106	172
106	675
106	117
106	37
106	197
106	400
106	150
106	374
107	512
107	564
107	14
133	162
133	128
133	425
133	213
133	672
133	110
134	377
136	436
136	719
136	122
136	575
138	200
138	467
139	200
179	611
179	397
179	139
179	556
179	324
229	387
229	683
229	464
229	560
230	49
230	582
230	60
230	441
230	619
230	71
230	41
231	665
274	173
274	621
274	214
274	353
274	154
274	52
274	695
274	62
319	224
321	642
321	245
321	129
323	598
323	36
323	624
113	326
114	413
114	666
114	657
118	306
119	249
120	293
122	267
122	731
122	525
122	639
122	248
122	374
122	536
122	227
122	1
122	420
122	491
124	663
124	506
5	25
5	335
5	166
8	208
16	208
20	93
20	610
20	81
21	345
21	614
21	258
21	336
21	722
22	726
22	266
22	231
22	525
22	248
22	460
22	270
22	194
22	526
22	565
22	142
22	566
23	191
24	456
24	325
25	225
27	341
27	640
27	396
28	333
28	493
29	208
30	75
31	531
31	125
31	104
31	364
31	319
32	221
32	546
33	238
33	688
34	316
35	316
35	338
35	359
36	256
37	256
38	256
39	23
40	53
40	88
40	526
40	667
41	31
41	578
41	266
41	45
41	487
41	666
41	294
41	392
41	566
42	355
43	655
44	650
44	132
44	171
45	377
46	377
47	377
49	638
49	377
49	662
49	289
125	393
125	307
125	216
50	629
50	601
50	701
50	32
50	525
50	472
50	732
50	376
50	248
50	400
50	271
50	374
50	536
51	377
51	638
52	610
53	231
53	248
53	525
53	610
54	343
54	306
54	138
56	122
56	89
58	377
71	610
71	408
71	360
71	632
73	132
73	171
74	517
74	610
75	517
75	526
76	666
76	518
76	98
77	208
79	532
79	430
79	553
79	184
81	192
81	87
82	581
82	39
82	185
82	97
82	373
83	377
83	413
85	42
86	438
86	276
86	176
87	615
87	222
88	44
89	237
89	310
90	108
90	395
90	208
90	407
91	240
91	26
91	501
91	362
91	483
91	269
91	630
91	193
91	297
91	215
91	409
91	211
92	377
92	270
94	377
95	417
95	377
95	175
95	526
96	81
96	377
97	710
97	377
98	710
98	377
177	13
177	432
177	550
177	447
177	714
108	377
108	638
109	377
110	157
110	686
111	554
111	55
111	223
111	526
111	407
111	63
112	342
112	473
126	159
126	64
126	571
126	527
127	442
127	34
129	44
129	668
129	633
129	586
130	377
131	543
131	316
132	338
132	24
132	312
132	636
132	5
132	600
132	306
144	136
144	561
144	327
144	86
144	259
144	567
144	652
145	303
145	301
145	478
147	85
147	313
147	253
147	314
149	611
149	656
149	120
149	201
152	426
152	385
153	441
153	246
153	2
153	134
153	637
153	10
153	318
157	452
157	228
157	590
157	592
157	380
157	533
157	27
157	568
157	235
157	660
157	145
157	91
157	522
159	328
160	389
160	415
160	99
163	443
163	105
163	286
164	450
164	720
164	168
166	90
166	680
167	261
167	320
167	384
167	334
167	644
171	706
171	161
171	107
172	303
172	232
172	202
172	478
180	295
180	322
181	611
182	602
182	673
186	454
186	459
186	16
241	124
241	716
241	653
241	167
243	418
246	274
247	257
247	664
247	283
247	11
247	151
247	219
247	82
247	243
247	20
250	528
250	612
251	471
251	61
251	713
251	3
252	718
260	300
260	204
261	418
262	262
263	611
265	715
265	404
265	217
265	631
265	447
267	303
267	317
267	478
268	725
269	232
269	202
269	212
269	329
269	478
269	616
269	298
269	95
269	15
269	181
269	725
270	303
270	202
270	478
276	146
276	714
277	279
277	386
279	303
279	478
282	461
282	676
282	164
286	643
286	19
286	401
286	169
286	693
288	439
288	38
288	115
289	402
289	645
290	56
290	444
290	272
290	100
291	734
291	547
291	727
291	152
291	277
292	628
292	537
293	141
293	540
293	515
293	368
293	587
293	670
294	728
294	195
295	584
295	538
295	189
295	163
296	346
296	367
301	484
302	689
302	410
302	398
303	160
304	494
304	588
304	17
304	542
304	51
304	182
304	220
305	224
305	285
306	224
306	572
307	290
309	446
309	648
309	687
309	233
309	626
309	126
309	451
309	190
309	6
309	445
309	729
310	308
310	416
311	403
311	604
311	375
311	594
311	624
311	4
312	287
313	557
313	149
315	723
322	177
322	330
322	103
322	595
322	513
322	58
324	455
324	381
324	92
325	203
326	485
326	474
326	622
327	206
329	331
329	305
329	328
330	419
330	382
332	406
332	71
334	111
334	448
335	196
335	147
335	447
336	440
336	505
336	74
338	674
338	488
338	691
339	83
339	572
340	348
340	658
340	291
340	583
340	510
340	209
341	224
341	476
342	607
342	635
342	625
342	323
343	183
343	421
344	65
345	606
345	224
350	130
350	708
350	609
351	84
351	468
351	677
351	495
351	198
352	186
353	349
355	380
355	681
355	339
355	697
355	71
356	284
356	399
356	427
356	143
357	332
359	72
359	721
359	580
361	596
362	551
362	418
364	634
365	497
367	711
367	187
369	102
369	148
369	661
370	321
371	369
372	411
374	702
374	22
374	288
374	123
375	78
375	678
375	106
376	573
376	730
376	207
377	585
377	591
380	239
382	684
382	174
382	121
383	458
383	118
383	311
383	422
384	387
384	428
384	264
384	140
384	552
384	275
384	96
388	414
388	509
388	247
388	503
389	244
390	158
391	229
394	479
394	405
394	597
394	465
394	268
394	178
395	299
395	618
395	230
399	21
399	500
399	344
399	562
399	457
399	278
328	466
328	350
328	613
400	658
400	441
400	114
400	470
402	224
402	449
402	199
61	704
61	302
366	671
366	624
366	328
65	40
65	394
65	155
65	135
65	28
65	361
65	68
65	66
67	33
67	603
72	610
78	365
78	8
78	498
78	669
78	354
78	70
78	529
84	530
93	216
100	57
100	236
100	50
100	133
100	356
100	276
100	241
100	502
100	176
102	608
102	132
102	171
102	614
102	137
103	166
103	641
103	496
103	31
103	525
103	675
103	248
115	70
123	361
128	433
128	292
128	700
128	379
128	18
128	80
128	316
128	338
137	523
137	431
137	357
137	589
142	703
142	69
150	548
150	647
150	35
150	624
150	545
162	511
170	685
173	432
173	252
173	698
173	165
184	224
184	22
222	576
222	569
237	490
237	7
237	435
242	716
242	653
242	328
244	119
244	260
244	315
244	654
244	30
271	282
271	462
271	712
271	620
284	281
284	71
285	617
287	116
308	463
331	627
331	250
349	370
349	507
379	508
379	524
379	520
379	43
379	733
379	737
379	623
381	577
381	734
381	579
381	659
381	265
393	378
393	340
393	21
401	9
401	347
401	681
\.


--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: -
--

COPY books (id, isbn, title, year_published, dewey_decimal, lcc_number, available_for_check_out, checked_out_at, collection_id, publisher_id, checked_out_by) FROM stdin;
2	9780671027421	The Water Nymph	2001	\N	\N	t	\N	1	219	\N
189	9782266128780	N comme nausee	2002	\N	\N	t	\N	1	188	\N
190	9780440102946	The American short story	1977	\N	\N	t	\N	1	198	\N
191	9780373109890	Velvet Promise	1987	\N	\N	t	\N	1	18	\N
192	9780812540017	Dead Simple	1999	813.540	\N	t	\N	1	36	\N
193	9780425177372	At Last	2000	\N	\N	t	\N	1	87	\N
194	9780416522600	Sarah's Nest Pb	1985	\N	\N	t	\N	1	256	\N
195	9780870697340	Warman's Antiques and Collectibles Price Guide 1995	1995	745.108	\N	t	\N	1	141	\N
196	9780851709611	Luchino Visconti	2003	\N	PN1998	t	\N	1	190	\N
197	9781593150006	Pessimisms	2003	817.000	\N	t	\N	1	164	\N
198	9780807841921	Wild Flowers of North Carolina	1987	\N	\N	t	\N	1	116	\N
199	9780671318468	Sentry Peak	2001	\N	\N	t	\N	1	129	\N
200	9780764313769	Complete Cookie Jar Book 3ED	0	\N	\N	t	\N	1	253	\N
201	9780373441150	Call of the wild	2001	\N	\N	t	\N	1	50	\N
202	9780345350589	The source of magic	1990	\N	\N	t	\N	1	250	\N
203	9780517223659	Anatomy, descriptive and surgical	1991	611.000	QM23	t	\N	1	26	\N
204	9780425042106	The Visitor	1979	\N	\N	t	\N	1	169	\N
206	9780671728137	The joys of Yiddish	1991	\N	\N	t	\N	1	171	\N
207	9780505523723	Dark Prince	1999	\N	\N	t	\N	1	255	\N
208	9782221082621	Le desir du cannibale: Roman	1996	\N	\N	t	\N	1	67	\N
209	9780849910579	A dance with deception	1993	277.308	BT738	t	\N	1	154	\N
210	9783426701966	Das Schwert von Avalon.	2000	\N	\N	t	\N	1	84	\N
211	9780451208675	No one left behind	2003	\N	DS79.744	t	\N	1	65	\N
212	9780688115524	Staying fat for Sarah Byrnes	1993	\N	PZ7	t	\N	1	181	\N
213	9789729278273	Angola, paz so com Muxima	1993	\N	\N	t	\N	1	130	\N
214	9782070382880	Un Homme Qui Dort	1990	848.000	\N	t	\N	1	239	\N
215	9780446516044	The dirty half dozen	1991	\N	\N	t	\N	1	199	\N
216	9780373036639	The Provocative Proposal	2001	\N	\N	t	\N	1	18	\N
217	9780836236545	I need help, too!	1997	741.597	PN6727	t	\N	1	125	\N
219	9780385297073	The naked heart	1989	\N	\N	t	\N	1	121	\N
220	9788447301263	No Digas Que Fue Un Sue�o	1998	\N	\N	t	\N	1	131	\N
221	9780892965199	Fallen into the pit	1994	823.912	PR6031	t	\N	1	152	\N
224	9780307119735	Just a daydream	1990	\N	PZ7	t	\N	1	133	\N
225	9780060196974	Art lover	2002	709.200	N5220	t	\N	1	184	\N
226	9780684864228	Between silk and cyanide	1999	\N	D810	t	\N	1	54	\N
228	9780312851910	Psychosphere	2001	\N	\N	t	\N	1	156	\N
273	9780783503257	Kids cooking	1998	641.512	TX652.5	t	\N	1	37	\N
232	9780064431033	This is the bear	1986	\N	PZ8.3	t	\N	1	186	\N
233	9781857990089	The Night	1993	\N	\N	t	\N	1	215	\N
234	9780891074090	Letters of Francis A. Schaeffer	1986	291.000	\N	t	\N	1	32	\N
235	9780349108155	Getting rid of Mister Kitchen	2001	\N	\N	t	\N	1	193	\N
236	9780451526571	Heart of darkness	1997	\N	\N	t	\N	1	24	\N
238	9780849954139	Thank you	1998	241.400	\N	t	\N	1	94	\N
239	9780373613595	The Mercenary	2003	\N	\N	t	\N	1	232	\N
240	9780393008326	The small room	1976	813.520	PZ3	t	\N	1	72	\N
298	9780245541506	Las ratas	1969	863.640	\N	t	\N	1	162	\N
80	9780138132316	Multivariate data analysis	2010	519.500	\N	t	\N	1	246	\N
223	9780670862931	Love of fat men	1997	821.914	\N	t	\N	1	61	\N
227	9780425103531	The Mysterious Mr. Quin	1994	\N	\N	t	\N	1	169	\N
1	9781593376864	Beginner's Guide to Day Trading Online	2007	332.640	\N	t	\N	1	201	\N
3	9781580625708	A Beginner's Guide to Short-Term Trading	2002	332.630	\N	t	\N	1	201	\N
4	9780534916459	A first course in the theory of linear statistical models	1991	519.530	QA279	t	\N	1	195	\N
6	9780321691699	A Second Course in Statistics: Regression Analysis	2012	519.536	\N	t	\N	1	246	\N
7	9781402017070	Advanced Sampling Theory with Applications	2003	519.520	\N	t	\N	1	56	\N
9	9780198566625	Model Based Methods for Sample Survey	2012	519.500	\N	t	\N	1	74	\N
10	9780534387754	An introduction to modern nonparametric statistics	2004	519.500	QA278.8	t	\N	1	173	\N
11	9780471899877	Analysis of survey data	2003	1.422	QA276	t	\N	1	115	\N
12	9780803930148	Analyzing complex survey data	1989	519.500	HN29	t	\N	1	257	\N
13	9780256117363	Applied linear statistical models	1996	519.535	QA278.2	t	\N	1	81	\N
14	9780195152968	Applied longitudinal data analysis	2003	1.400	\N	t	\N	1	58	\N
15	9780387953472	Applied multivariate analysis	2002	519.535	QA278	t	\N	1	56	\N
17	9780131877153	Applied multivariate statistical analysis	2007	519.535	J7	t	\N	1	114	\N
18	9780130417732	Applied multivariate statistical analysis	1992	519.535	QA278	t	\N	1	246	\N
19	9780471170822	Applied regression analysis	1998	519.500	QA278.2	t	\N	1	115	\N
385	9780759232464	Castle Murders	2003	\N	\N	t	\N	1	108	\N
60	9780471698685	Internet, mail, and mixed-mode surveys	2009	300.723	HM538	t	\N	1	175	\N
62	9780486650845	Introduction to difference equations	1986	515.625	QA431	t	\N	1	90	\N
63	9780387329178	Introduction to variance estimation	2007	519.538	\N	t	\N	1	56	\N
64	9780139316500	Japanese candlestick charting techniques	1991	332.632	HG4638	t	\N	1	217	\N
66	9780471042990	Joint application development	1995	4.210	QA76.9	t	\N	1	115	\N
68	9780201824780	Linear algebra and its applications	1997	512.500	QA184	t	\N	1	64	\N
69	9780321385178	Linear Algebra and Its Applications	2012	512.500	\N	t	\N	1	245	\N
70	9780131907294	Linear algebra	1997	512.500	QA184	t	\N	1	246	\N
99	9780470454602	Sampling statistics	2009	519.520	QA276.6	t	\N	1	115	\N
101	9781555444211	SAS	1991	519.500	\N	t	\N	1	23	\N
135	9780472065912	Value change in global perspective	1995	306.094	HN371	t	\N	1	91	\N
342	9780881846409	On the run	1992	\N	GV865	t	\N	1	85	\N
104	9781555444303	SAS System for Linear Models, Third Edition	1991	519.503	\N	t	\N	1	227	\N
105	9780312325695	Short term trading in the new stock market	2005	332.632	HG6041	t	\N	1	231	\N
106	9780486668932	Singular Integral Equations	1992	515.450	\N	t	\N	1	90	\N
107	9781400049523	Slander: Liberal Lies About the American Right	2002	320.520	\N	t	\N	1	237	\N
121	9780312136345	The Bedford Reader	1997	808.043	\N	t	\N	1	258	\N
133	9781400050321	Treason	2003	320.510	E743	t	\N	1	155	\N
134	9780444703576	Unified theory and strategies of survey sampling	1988	519.520	QA276.6	t	\N	1	117	\N
136	9780789708151	VBScript by example	1996	5.276	QA76.73	t	\N	1	267	\N
138	9780596527211	XSLT	2001	5.720	QA76.73	t	\N	1	168	\N
139	9780764536519	XSLT for dummies	2002	5.720	QA76.73	t	\N	1	101	\N
140	9780449909287	Operating instructions	1994	813.540	PS3562	t	\N	1	242	\N
141	9780373708352	The doctor's daughter	1999	\N	\N	t	\N	1	18	\N
169	9781551666488	Deadly Intent	2003	\N	\N	t	\N	1	161	\N
179	9780684848150	Underworld	1998	\N	PS3554	t	\N	1	118	\N
229	9781879181304	The Pleiadian Agenda	1995	\N	\N	t	\N	1	78	\N
230	9780671042974	Belle Terre	2000	\N	\N	t	\N	1	171	\N
231	9780385083744	Toulouse-Lautrec	1973	\N	ND553	t	\N	1	68	\N
245	9781551665511	All Fall Down	2000	813.540	\N	t	\N	1	161	\N
274	9780020420101	Martin Luther King, Jr	1986	323.409	E185.97	t	\N	1	4	\N
275	9780821748916	Lady Of The Forest	1999	813.540	\N	t	\N	1	146	\N
278	9783442309986	Ich bin gekommen.	2002	\N	\N	t	\N	1	98	\N
319	9780533138623	One Night in a Strange Blue Light	2002	\N	\N	t	\N	1	113	\N
320	9780449237823	CAVES OF STEEL	1981	\N	\N	t	\N	1	82	\N
321	9780446673921	The little yoga book	1999	613.705	BL1238.52	t	\N	1	199	\N
323	9780394534329	The middle heart	1996	813.540	PS3562	t	\N	1	148	\N
113	9780321388834	Student Study Guide for Linear Algebra and Its Applications	2012	512.000	\N	t	\N	1	247	\N
114	9780471483489	Survey methodology	2004	1.433	HA31.2	t	\N	1	179	\N
116	9781575210735	Teach Yourself Javascript in a Week	1996	5.130	\N	t	\N	1	210	\N
117	9780672310454	Teach Yourself Transact-SQL in 21 Days	1997	5.750	\N	t	\N	1	210	\N
118	9780131345973	Technical analysis plain and simple	2006	332.632	HG4529	t	\N	1	268	\N
119	9780387988641	Testing statistical hypotheses	2005	519.500	QA277	t	\N	1	56	\N
120	9780226092539	The American voter	1960	324.000	\N	t	\N	1	264	\N
122	9780387848570	The elements of statistical learning	2009	6.300	\N	t	\N	1	56	\N
124	9780879422936	The probability tutoring book	1993	620.002	TA340	t	\N	1	163	\N
5	9780131367364	Practical Guide to Linux Commands, Editors, and Shell Programming, A	2010	5.432	\N	t	\N	2	95	\N
8	9780471113386	An introduction to categorical data analysis	1996	519.500	QA278	t	\N	2	115	\N
16	9780534237967	Applied multivariate methods for data analysts	1998	519.535	QA278	t	\N	2	77	\N
20	9780803945401	Applied regression analysis, linear models, and related methods	1997	300.015	HA31.3	t	\N	1	134	\N
21	9780137436422	Applied statistics and the SAS programming language	1997	519.503	QA276.4	t	\N	1	246	\N
22	9781420080667	Applied Survey Data Analysis	2010	1.422	\N	t	\N	1	149	\N
23	9780486420790	Basic set theory	2002	511.322	QA248	t	\N	1	90	\N
24	9780764516962	Bioinformatics for dummies	2003	570.000	C6	t	\N	1	261	\N
25	9780521574716	Bootstrap methods and their application	1997	519.544	QA276.8	t	\N	1	165	\N
26	9781599941899	Building Web Applications With SAS/IntrNet: A Guide to the Application Dispatcher	2007	5.200	\N	t	\N	1	6	\N
27	9780521009621	Calculated bets	2001	511.000	QA401	t	\N	1	122	\N
28	9780534218034	Student solutions manual for Stewart's Calculus, third edition	1995	515.000	\N	t	\N	1	106	\N
29	9780471360933	Categorical data analysis	2002	519.535	QA278	t	\N	1	151	\N
30	9780841501911	CIA: the myth and the madness	2000	353.000	JK468	t	\N	1	209	\N
31	9780226104416	Collective action and the civil rights movement	1991	323.100	HB846.5	t	\N	1	264	\N
32	9780691130965	Complex adaptive systems	2007	300.100	\N	t	\N	1	109	\N
33	9780124262805	Current topics in survey sampling	1981	1.433	HN29	t	\N	1	111	\N
34	9780471383390	Day trade futures online	2000	332.640	HG4515.95	t	\N	1	115	\N
35	9780471331209	Day trade online	1999	332.640	HG4515.95	t	\N	1	179	\N
36	9780387985619	Design and analysis of experiments	1999	1.434	QA279	t	\N	1	56	\N
37	9780471551782	Design and analysis of experiments	1994	1.434	QA279	t	\N	1	135	\N
38	9780471157465	Design and analysis of experiments	1997	1.400	QA279	t	\N	1	115	\N
39	9781584889236	Design of Experiments: An Introduction Based on Linear Models	2011	519.570	\N	t	\N	1	269	\N
40	9780534368340	Design of experiments	2000	1.422	Q182.3	t	\N	1	189	\N
41	9780521889452	Designing effective Web surveys	2008	300.723	HM538	t	\N	1	165	\N
42	9780262520409	Discrete multivariate analysis	2000	519.500	\N	t	\N	1	100	\N
43	9780879440091	Economic survey methods	2000	330.000	HC28	t	\N	1	233	\N
44	9780534243425	Elementary Survey Sampling	1995	519.500	\N	t	\N	1	77	\N
45	9780534921859	Elementary survey sampling	1990	519.520	HA31.2	t	\N	1	195	\N
46	9780137435760	Elements of sampling theory and methods	1999	519.520	QA276.6	t	\N	1	246	\N
47	9780792340454	Elements of survey sampling	1996	1.422	QA276.6	t	\N	1	216	\N
48	9781584884156	Epidemiology	2005	614.407	\N	t	\N	1	45	\N
49	9780470011331	Estimation in surveys with nonresponse	2005	519.544	QA276.8	t	\N	1	115	\N
125	9780470973929	The R Book	2013	519.503	\N	t	\N	1	115	\N
299	9780130338464	El t�nel	1992	468.000	\N	t	\N	1	246	\N
50	9780471699460	Experiments: Planning, Analysis, and Optimization	2009	519.570	\N	t	\N	1	115	\N
51	9780471025634	Foundations of inference in survey sampling	1977	519.520	QA276.6	t	\N	1	115	\N
52	9780412317606	Generalized linear models	1998	519.500	QA276	t	\N	1	46	\N
53	9780470073711	Generalized, linear, and mixed models	2008	519.535	QA279	t	\N	1	115	\N
54	9780471295426	Getting started in technical analysis	1999	332.632	\N	t	\N	1	179	\N
55	9781592801985	Hit and Run Trading	2004	332.640	\N	t	\N	1	254	\N
56	9780596000264	HTML & XHTML, the definitive guide	2000	5.700	\N	t	\N	1	168	\N
57	9781848720473	IBM SPSS Statistics 18 Made Simple	2010	5.550	\N	t	\N	1	86	\N
58	9780387707822	Indirect sampling	2007	519.500	QA276.6	t	\N	1	56	\N
71	9780387950273	Linear mixed models for longitudinal data	2000	519.500	QA279	t	\N	1	56	\N
73	9781584884255	Linear Models with R	2005	519.500	\N	t	\N	1	45	\N
74	9780534980382	Matrices with applications in statistics	1983	512.943	QA188	t	\N	1	230	\N
75	9780470009611	Matrix algebra useful for statistics	2006	512.943	QA188	t	\N	1	151	\N
76	9780471458418	Methods for testing and evaluating survey questionnaires	2004	300.723	HM538	t	\N	1	151	\N
77	9780471418894	Methods of multivariate analysis	2002	519.535	QA278	t	\N	1	135	\N
79	9780470740521	Multiple imputation and its application	2013	610.724	\N	t	\N	1	115	\N
81	9780525953722	No Easy Day	2012	958.000	\N	t	\N	1	212	\N
82	9780486682525	Number theory	1994	512.700	QA241	t	\N	1	90	\N
83	9780471939344	Practical methods for design and analysis of complex surveys	1995	1.400	QA276.6	t	\N	1	115	\N
85	9780763702922	Programming and problem solving with C++	1997	5.133	\N	t	\N	1	249	\N
86	9780763717636	Programming and problem solving with Visual Basic. NET	2003	5.277	QA76.73	t	\N	1	12	\N
87	9780735621831	Programming Microsoft Visual Basic 2005	2006	5.277	\N	t	\N	1	33	\N
88	9780312654801	Public opinion	1979	303.381	HN90	t	\N	1	231	\N
89	9780387985220	Random number generation and Monte Carlo methods	1998	519.282	QA298	t	\N	1	56	\N
90	9781557982735	Reading and understanding multivariate statistics	1995	1.400	QA278	t	\N	1	224	\N
91	9780312173005	Rogue regimes	1998	327.117	D412.7	t	\N	1	231	\N
92	9780340545539	Sample survey principles and methods	1991	519.500	\N	t	\N	1	147	\N
94	9780534353612	Sampling	1999	519.500	HA31.2	t	\N	1	77	\N
95	9780534979867	Sampling for health professionals	1980	362.107	RA409	t	\N	1	123	\N
96	9781584882145	Sampling methodologies	2000	519.520	HA31.2	t	\N	1	45	\N
97	9780471155751	Sampling of populations	1999	304.602	HB849.49	t	\N	1	115	\N
98	9780471508229	Sampling of populations	1991	304.602	HB849.49	t	\N	1	115	\N
177	9780743407076	Grand Avenue	2001	\N	PR9199.3	t	\N	1	171	\N
108	9780471413745	Small area estimation	2003	519.520	QA276.6	t	\N	1	151	\N
109	9780486646848	Some theory of sampling	2000	311.000	HA33	t	\N	1	90	\N
110	9780387988634	Statistical consulting	2002	1.422	HA29	t	\N	1	56	\N
111	9780314068064	Statistics for the behavioral sciences	1996	519.502	BF39	t	\N	1	53	\N
112	9780471818847	Stochastic simulation	1987	1.434	QA76.9	t	\N	1	135	\N
188	9782070715237	La Disparition	1990	\N	\N	t	\N	1	144	\N
126	9780199747047	The science of web surveys	2013	300.723	HM538	t	\N	1	58	\N
127	9780878915156	The statistics problem solver	2000	519.508	QA276.2	t	\N	1	234	\N
129	9780742547179	The voter's guide to election polls	2008	303.381	HN90	t	\N	1	17	\N
131	9780471384731	Trade stocks online	2000	332.642	\N	t	\N	1	115	\N
132	9780764556890	Trading for dummies	2004	332.640	\N	t	\N	1	115	\N
178	9780373071494	Quest of the Eagle	1986	\N	\N	t	\N	1	232	\N
363	9780027366600	Branigan's Dog	1981	\N	\N	t	\N	1	207	\N
143	9788485229604	La cr�nica del Per�	1984	\N	\N	t	\N	1	252	\N
144	9780812971064	Reading Lolita in Tehran	2003	\N	PE64	t	\N	1	166	\N
145	9780375700699	Trap Line	1998	\N	\N	t	\N	1	96	\N
146	9780553213539	The Invisible Man	1983	\N	\N	t	\N	1	270	\N
147	9781573247023	The Food Revolution: How Your Diet Can Help Save Your Life and Our World	2001	\N	\N	t	\N	1	40	\N
149	9781932560497	Bedtime Stories for Women	2003	\N	\N	t	\N	1	248	\N
151	9780553158939	The ghost in the bell tower	1992	\N	\N	t	\N	1	31	\N
152	9780807530818	The guide dog mystery	1996	\N	PZ7	t	\N	1	75	\N
153	9781591824091	Chobits, Book 8	2003	\N	\N	t	\N	1	9	\N
154	9780425170502	White Horses	1999	\N	\N	t	\N	1	87	\N
155	9780553057454	Confessions	1990	813.540	PS3569	t	\N	1	238	\N
156	9780451156457	The New Left	1988	303.484	\N	t	\N	1	185	\N
157	9780966080520	Day job	1998	\N	HF5548.8	t	\N	1	143	\N
158	9780553288551	The wind dancer	1991	\N	\N	t	\N	1	238	\N
159	9780373707010	Hot & bothered	1996	\N	\N	t	\N	1	50	\N
160	9780440213291	The copper beech	1993	\N	\N	t	\N	1	198	\N
161	9780440222828	The Mercy Rule	1999	\N	\N	t	\N	1	51	\N
163	9780395440902	The boy of the three-year nap	1988	398.200	PZ8.1	t	\N	1	112	\N
164	9780840758637	The confessions of Saint Augustine	1983	\N	BR65	t	\N	1	73	\N
166	9780060960803	The movie lover's guide to New York	1988	384.810	F128.18	t	\N	1	153	\N
167	9780553560725	A brilliant madness	1993	\N	D877	t	\N	1	238	\N
168	9780060809461	The Fires of Fu Manchu	1988	823.914	\N	t	\N	1	20	\N
171	9780425089514	The tunnels of Cu Chi	1997	959.704	DS559.8	t	\N	1	140	\N
172	9780425180006	Nursery Crimes	2001	\N	\N	t	\N	1	87	\N
175	9780307085740	Day on Sesame Street	1994	\N	\N	t	\N	1	107	\N
176	9780553492156	Elizabeth's Secret Diary, Volume III	1997	\N	\N	t	\N	1	38	\N
272	9783499503665	Ingmar Bergman: Mit Selbstzeugnissen und Bilddokumenten	1987	\N	\N	t	\N	1	160	\N
180	9780201632958	Mama makes up her mind	1993	814.540	PN6162	t	\N	1	64	\N
181	9780452281943	Tomato Red	2000	\N	\N	t	\N	1	176	\N
182	9780415165235	American civilization	1998	973.000	E169.1	t	\N	1	102	\N
183	9781555745899	A Second-Hand Christmas	1991	\N	\N	t	\N	1	88	\N
185	9780330307246	Wallis: Secret Lives of the Duchess of Windsor	1989	\N	\N	t	\N	1	42	\N
186	9780395368954	A porcupine named Fluffy	1986	\N	PZ7	t	\N	1	112	\N
187	9783505072925	Highway-Melodie: Mit dem Motorrad 20 000 km quer durch die USA	1981	\N	\N	t	\N	1	266	\N
241	9780060525194	A Wanted Man	2004	\N	\N	t	\N	1	229	\N
243	9780805028188	"C" is for corpse	1986	\N	\N	t	\N	1	251	\N
246	9780907040712	The firewalkers	1985	\N	\N	t	\N	1	213	\N
247	9780151970872	Wind, sand, and stars	1992	848.912	PQ2637	t	\N	1	110	\N
248	9780440224228	Dream lover	1997	\N	\N	t	\N	1	121	\N
249	9780446314862	To Kill a Mockingbird	1982	\N	\N	t	\N	1	80	\N
250	9780743203920	Great presidential wit	2001	\N	E176.1	t	\N	1	128	\N
251	9780961815219	100 hikes in the Central Oregon Cascades	1991	\N	\N	t	\N	1	265	\N
252	9780006377214	A sparrow's flight	1991	\N	\N	t	\N	1	196	\N
253	9780373625406	Nightmare Passage	1997	\N	\N	t	\N	1	3	\N
255	9788472235717	Sin Plumas	2002	370.000	\N	t	\N	1	1	\N
256	9780440217701	The Five Minute Lawyer's Guide to Bad Debts	1995	\N	\N	t	\N	1	198	\N
257	9780595199426	In His Corner	2001	813.000	\N	t	\N	1	145	\N
258	9780872398511	Three Hundred Sixty-Five Devotions	1985	\N	\N	t	\N	1	97	\N
259	9780553380989	Once Removed	2004	813.000	\N	t	\N	1	158	\N
260	9780895862754	Complete guide to prescription & non-prescription drugs	1983	615.100	\N	t	\N	1	62	\N
261	9780140075632	The black seraphim	1985	823.914	PR6013	t	\N	1	205	\N
262	9780449223147	Best Defense	1995	\N	\N	t	\N	1	82	\N
263	9780312971205	The House That Ate the Hamptons	2000	\N	\N	t	\N	1	231	\N
264	9780425116739	Lightning Int	1988	\N	\N	t	\N	1	169	\N
265	9780826322524	El puente	2000	813.600	PS3568	t	\N	1	103	\N
266	9780893758271	Demon Cat and Other Strange Tales	1983	\N	\N	t	\N	1	70	\N
267	9780758206244	Burning Bridges	2004	\N	\N	t	\N	1	240	\N
268	9780451212856	Early eight	2004	\N	\N	t	\N	1	57	\N
269	9780399152191	Trace	2004	813.540	PS3553	t	\N	1	159	\N
270	9781892343253	Number, Please	2002	\N	\N	t	\N	1	191	\N
276	9780060237622	The borning room	1991	\N	PZ7	t	\N	1	184	\N
279	9780671003111	SHINY WATER	1998	\N	\N	t	\N	1	219	\N
280	9782868698407	La surproductivit�: R�cit	1993	\N	\N	t	\N	1	21	\N
282	9780590528375	Jesse	1996	\N	\N	t	\N	1	150	\N
283	9783442441099	Die Kanzlei.	1998	\N	\N	t	\N	1	98	\N
286	9780373244201	Another Man'S Children	2001	813.000	\N	t	\N	1	232	\N
288	9780071371780	E-strategy pure & simple	2000	658.840	\N	t	\N	1	178	\N
289	9780670864010	Becoming visible	1998	306.766	HQ75.16	t	\N	1	260	\N
290	9780919433533	Uneasy patriots	1988	971.203	F1060.92	t	\N	1	170	\N
291	9781886913042	Without a Guide	1996	910.820	\N	t	\N	1	119	\N
292	9780062510488	Essential Tibetan Buddhism	1995	294.392	BQ7604	t	\N	1	172	\N
293	9780965834506	Bloodwalk	1997	\N	\N	t	\N	1	55	\N
294	9780889088887	Professional selling	1991	658.850	\N	t	\N	1	27	\N
295	9780192100436	David Copperfield	1999	823.800	PR4558	t	\N	1	58	\N
296	9780300037791	J. M. W. Turner	1987	760.092	N6797	t	\N	1	138	\N
297	9780553280609	Gentle Conqueror	1989	813.540	\N	t	\N	1	158	\N
300	9780689120831	Landscape of lies	1990	823.914	PR6073	t	\N	1	207	\N
301	9780425059609	Dog training my way	1982	\N	\N	t	\N	1	140	\N
302	9780394429823	Iberia, Spanish travels and reflections	1968	\N	\N	t	\N	1	187	\N
303	9780449206362	When Eight Bells Toll	1983	\N	\N	t	\N	1	82	\N
304	9780064472395	For real / by Christa Roberts	2000	\N	PZ7	t	\N	1	124	\N
305	9780515111972	To Scotland And Love	1993	813.000	\N	t	\N	1	104	\N
306	9780786220298	No Time for Love	1999	823.912	\N	t	\N	1	183	\N
307	9780451164537	True Crime Stories	1989	\N	\N	t	\N	1	139	\N
309	9781576107119	MCSE Windows 2000 network	2000	5.714	QA76.3	t	\N	1	19	\N
310	9780064472067	Stephen Fair	2000	\N	PZ7	t	\N	1	44	\N
311	9780891078067	A gentle calling	1994	813.540	PS3553	t	\N	1	32	\N
312	9780892836529	Study Guide for Charles Colson's Against the Night	1989	\N	\N	t	\N	1	25	\N
313	9780006380924	The Kenneth Williams letters	1995	792.028	PN2598	t	\N	1	184	\N
314	9780415006651	Selected poetry and prose	1988	821.500	PR3622	t	\N	1	102	\N
315	9780340125540	Travelling in	1971	200.190	BV4832.2	t	\N	1	28	\N
316	9780553245257	Sabotage	1984	\N	\N	t	\N	1	238	\N
317	9780373018307	Falcon on the mountain	1974	\N	\N	t	\N	1	50	\N
318	9780823048014	Simple Outdoor Style	1998	\N	\N	t	\N	1	132	\N
322	9780060953232	The language of choice theory	1999	158.200	BF637	t	\N	1	218	\N
324	9780965583770	Red sky in mourning	1998	\N	\N	t	\N	1	120	\N
325	9780863162091	Aaron and Gayla's counting book	1994	\N	\N	t	\N	1	243	\N
326	9780300002270	Sun Chief	1963	979.135	E99	t	\N	1	138	\N
327	9780310225690	Raising great kids	1999	248.845	BV4529	t	\N	1	43	\N
329	9780385306775	Nobody's angel	1992	813.540	PS3568	t	\N	1	121	\N
330	9780812517842	The fury	1994	\N	\N	t	\N	1	259	\N
332	9780553379303	The memory of fire	2000	813.540	PS3556	t	\N	1	238	\N
333	9780670703715	The Thomas Street horror	1982	813.540	PS3566	t	\N	1	8	\N
334	9780139180538	Dave Sperling's Internet guide	1998	428.003	\N	t	\N	1	246	\N
335	9780679772583	Time will darken it	1997	\N	PS3525	t	\N	1	241	\N
336	9780486400754	Italian Renaissance Costumes Paper Dolls (Paper Doll Series)	1998	\N	\N	t	\N	1	90	\N
337	9780141185088	Cannery Row	2000	813.520	\N	t	\N	1	2	\N
338	9780345337603	A gift of hope	1986	\N	\N	t	\N	1	250	\N
339	9780380823130	Wildfires Book Four: The Story of Canada	1983	813.540	\N	t	\N	1	126	\N
340	9780399232480	Redwall Map & the Redwall Riddler	1998	\N	\N	t	\N	1	142	\N
341	9783426611692	Die Roten Wasser Von Bath	1999	\N	\N	t	\N	1	202	\N
343	9780262581301	Postmetaphysical thinking	1994	\N	B3258	t	\N	1	100	\N
344	9780140301199	Tales of the Greek heroes	1958	398.220	\N	t	\N	1	263	\N
345	9781863739313	The Quicksand Pony	1997	\N	\N	t	\N	1	5	\N
347	9780441372768	Ironbrand	1984	\N	\N	t	\N	1	87	\N
348	9781850297062	Chateau Cuisine	1995	\N	\N	t	\N	1	69	\N
350	9780907871323	Hermit of Peking	1993	\N	DS734.9	t	\N	1	29	\N
351	9780836190809	Armageddon and the peaceable kingdom	1999	236.900	\N	t	\N	1	211	\N
352	9788489954014	Tapas and More Great Dishes from Spain	1997	641.000	\N	t	\N	1	71	\N
353	9780830716074	What the Bible Is All About	1993	\N	\N	t	\N	1	182	\N
354	9780395081778	All my pretty ones	1962	\N	\N	t	\N	1	112	\N
355	9780886777425	God's dice	1997	\N	\N	t	\N	1	35	\N
356	9780898400922	The well family book	1985	613.000	RA777.7	t	\N	1	192	\N
357	9780811800655	Best restaurants of San Francisco	1991	647.958	TX907.3	t	\N	1	235	\N
358	9780316807098	Space station seventh grade	1982	\N	PZ7	t	\N	1	203	\N
359	9780819869647	The splendor of truth	1993	\N	BX860	t	\N	1	39	\N
360	9780553205985	Hiroshima	1981	\N	\N	t	\N	1	226	\N
361	9781564651587	A Dog Owner's Guide to Training Your Dog	1993	636.000	\N	t	\N	1	206	\N
362	9780449908815	Danger zones	1996	823.914	PR6052	t	\N	1	242	\N
364	9780439155311	Beautiful You!	2000	646.705	\N	t	\N	1	150	\N
365	9781558704411	The Crafts Supply Sourcebook: A Comprehensive Shop-by-Mail Guide for Thousands of Craft Materials	1996	745.503	\N	t	\N	1	60	\N
367	9780866051514	A Skeptics Quest	1984	\N	\N	t	\N	1	14	\N
368	9780151585885	The meeting at Telgte	1981	833.914	PT2613	t	\N	1	110	\N
369	9780813511771	Raising a baby the government way	1986	\N	\N	t	\N	1	200	\N
370	9780877770343	P. S. your not listening	1972	371.940	LC4169	t	\N	1	13	\N
371	9780590412469	The Taking of Mariasburg	1989	\N	\N	t	\N	1	221	\N
372	9780967200606	Northwoods pulp	1999	\N	\N	t	\N	1	11	\N
373	9782912517067	L'invitation � la vie conjugale	1998	\N	\N	t	\N	1	89	\N
374	9780373077373	Michael'S House	1996	813.000	\N	t	\N	1	232	\N
375	9780385468787	101 things you can do for our children's future	1994	\N	\N	t	\N	1	16	\N
376	9780694003211	Maggie Simpson's Book of Animals	1991	591.000	\N	t	\N	1	92	\N
377	9780679882596	Xena Warrior Princess: Princess in Peril	1996	\N	\N	t	\N	1	262	\N
380	9780688111274	Mr. Food cooks like Mama	1992	\N	TX714	t	\N	1	63	\N
382	9780140351323	Under the Lilacs	1991	\N	\N	t	\N	1	41	\N
383	9780684834795	Kindling the flame	1998	\N	BM726	t	\N	1	259	\N
384	9780140192469	The sleepwalkers	1990	523.101	\N	t	\N	1	2	\N
386	9780316316200	The 60th monarch	1974	813.540	PZ3	t	\N	1	7	\N
387	9780671559250	With mercy toward none	1985	\N	\N	t	\N	1	129	\N
388	9781562941420	How On Earth Do We Recycle Met	1992	669.000	\N	t	\N	1	174	\N
389	9781557733979	The Baby	1990	813.540	\N	t	\N	1	76	\N
390	9780517122266	10, 000 garden questions answered by 20 experts	1994	635.000	SB453	t	\N	1	52	\N
391	9781570640711	What Can It Be?: A Barney Book and Tape	1996	\N	\N	t	\N	1	30	\N
394	9780889104624	The girl wants to	1994	810.804	\N	t	\N	1	223	\N
395	9780553486025	No escape!	1998	\N	\N	t	\N	1	158	\N
396	9780395416495	Diary of a yuppie	1986	813.540	PS3501	t	\N	1	112	\N
397	9780449243114	The Spinoza of Market Street	1981	\N	\N	t	\N	1	167	\N
398	9780877734611	The Life and Letters of Tofu Roshi	1988	818.541	\N	t	\N	1	180	\N
399	9780874771596	Overcoming writing blocks	1980	808.020	PN147	t	\N	1	214	\N
328	9780805400069	Fit to Be Mom	1996	613.000	\N	t	\N	2	127	\N
400	9780425170618	Delusions of Grandeur	1997	\N	\N	t	\N	1	87	\N
402	9780745168081	The Handmaid's Tale	1999	813.000	\N	t	\N	1	236	\N
61	9780761951612	Introducing ANOVA and ANCOVA	2001	519.538	QA279	t	\N	2	93	\N
366	9780553095098	Deception	1993	813.540	PS3561	t	\N	2	238	\N
378	9780451209191	Midsummer Magic	2003	\N	\N	t	\N	2	34	\N
65	9780764535420	JavaServer pages	2001	5.276	TK5105.8885	t	\N	2	101	\N
67	9780763717087	Lebesgue integration on Euclidean space	2001	515.420	QA312	t	\N	2	249	\N
72	9780471754985	Linear models in statistics	2008	519.535	QA276	t	\N	2	151	\N
78	9781584883258	Modelling survival data in medical research	2003	610.000	\N	t	\N	2	45	\N
84	9780534229023	Principles of biostatistics	2000	570.152	QH323.5	t	\N	2	48	\N
93	9780470402313	Sampling	2012	519.520	\N	t	\N	2	115	\N
100	9780672329845	Sams teach yourself Visual BASIC 2008 in 24 hours	2008	5.276	\N	t	\N	2	204	\N
102	9780471221746	SAS for linear models	2002	519.535	QA276.4	t	\N	2	227	\N
103	9781555443719	SAS Language and Procedures	1989	519.503	\N	t	\N	2	227	\N
115	9780387953991	Survival analysis	2003	610.000	\N	t	\N	2	56	\N
123	9780201634594	The Java application programming interface	1996	5.133	QA76.73	t	\N	2	228	\N
128	9780470448489	The truth about day trading stocks	2009	332.632	HG4515.95	t	\N	2	115	\N
137	9780669388138	Writers INC	1996	808.042	PE1408	t	\N	2	10	\N
142	9780812513738	The shadow rising	1993	\N	\N	t	\N	2	194	\N
148	9780563537236	Down to Earth	2000	\N	\N	t	\N	2	137	\N
150	9780345406415	Rookery blues	1996	\N	\N	t	\N	2	250	\N
162	9780609608739	Justice	2001	\N	\N	t	\N	2	225	\N
165	9782070363513	Au-dessous du volcan	1973	\N	\N	t	\N	2	157	\N
170	9780395078655	A field guide to the butterflies	1973	\N	\N	t	\N	2	112	\N
173	9780758203007	Circle of five	2003	813.600	PS3618	t	\N	2	99	\N
174	9780786015504	Perfect Poison	2003	\N	\N	t	\N	2	15	\N
184	9780373167197	Princess In Denim	1998	813.000	\N	t	\N	2	18	\N
218	9780425068045	They came to Baghdad	1994	\N	\N	t	\N	2	49	\N
222	9780299196806	A passion to preserve	2004	306.766	HQ75.7	t	\N	2	208	\N
237	9780449204177	Mrs. Pollifax on the China station	1984	\N	\N	t	\N	2	167	\N
242	9780373791484	His hot number	2004	\N	\N	t	\N	2	18	\N
244	9780312194062	The marrow of tradition	2002	\N	PS1292	t	\N	2	83	\N
254	9780449139424	Loneliness is Rotting on a Book Rack	1981	\N	\N	t	\N	2	250	\N
271	9780451410276	Final justice	2002	\N	\N	t	\N	2	244	\N
281	9780765194251	The Barn	1997	728.922	\N	t	\N	2	136	\N
284	9780671578800	Balshazzar's serpent	2000	813.540	PS3553	t	\N	2	129	\N
285	9780070066168	Casebook in abnormal psychology	1996	\N	\N	t	\N	2	178	\N
287	9780397013159	The last mystery of Edgar Allan Poe	1978	813.540	PS3563	t	\N	2	222	\N
308	9780671797355	The little plane	1993	\N	\N	t	\N	2	66	\N
331	9780723002741	The Times concise atlas of world history	1985	\N	\N	t	\N	2	79	\N
346	9780425046845	Time Enough For Love	1980	\N	\N	t	\N	2	169	\N
349	9780688032364	So long until tomorrow	1977	70.924	CT275	t	\N	2	63	\N
379	9781577656760	Adventures of Huckleberry Finn	2002	\N	\N	t	\N	2	47	\N
381	9781879288720	The Book of Margery Kempe	1996	248.209	\N	t	\N	2	91	\N
392	9780877951995	Starett	1978	\N	PS3554	t	\N	2	105	\N
393	9781559343794	Human Motor Development	1995	155.412	\N	t	\N	2	59	\N
401	9780140236460	Wuthering Heights According to Spike Milligan	1995	\N	\N	t	\N	2	22	\N
205	9780002219983	Contract	1980	\N	\N	t	\N	1	177	\N
130	9780387951089	Topics in survey sampling	2001	519.520	QA276.6	t	2017-10-17 11:09:59.658777	1	56	38
59	9780465025220	Intellectuals and Society	2011	320.000	\N	t	2017-10-17 11:09:59.658777	2	197	38
277	9780061042546	The Kennedy contract	1993	364.152	E842.9	t	2017-09-17 11:13:46.204238	1	220	38
\.


--
-- Name: books_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('books_id_seq', 402, true);


--
-- Data for Name: collections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY collections (id, name, checkout_duration, fine_per_day) FROM stdin;
1	Standard	14 days	$0.25
2	Special	5 days	$1.00
\.


--
-- Data for Name: fines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY fines (id, patron_id, book_id, date, amount) FROM stdin;
1	38	277	2017-10-17	$32.00
\.


--
-- Name: fines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('fines_id_seq', 9, true);


--
-- Data for Name: patrons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY patrons (id, name, email) FROM stdin;
1	Guido Newick	gnewick0@cdc.gov
2	Shayna Sonschein	ssonschein1@infoseek.co.jp
3	Jojo Yesson	jyesson2@time.com
4	Drusilla Stanhope	dstanhope3@hc360.com
5	Leora Cleef	lcleef4@seesaa.net
6	Noam Giblin	ngiblin5@rakuten.co.jp
7	Augustina Hammill	ahammill6@bbb.org
8	Margret Bedow	mbedow7@jugem.jp
9	Emalee Luard	eluard8@ucsd.edu
10	Debbie Foster-Smith	dfostersmith9@wsj.com
11	Matilda Rebbeck	mrebbecka@tiny.cc
12	Bartram Pernell	bpernellb@bravesites.com
13	Tarra Menary	tmenaryc@cafepress.com
14	Benedicta Whebell	bwhebelld@hhs.gov
15	Clarita Normant	cnormante@latimes.com
16	Karita Krysztofiak	kkrysztofiakf@bing.com
17	Sarita Greystoke	sgreystokeg@tripod.com
18	Hildegaard Tovey	htoveyh@usnews.com
19	Eyde Whotton	ewhottoni@umich.edu
20	Stanly Pomfrey	spomfreyj@mapy.cz
21	Celisse Schneidar	cschneidark@360.cn
22	Lisle O'Dowd	lodowdl@google.com.br
23	Eldredge Baskerville	ebaskervillem@usda.gov
24	Ikey Mitkcov	imitkcovn@joomla.org
25	Sena Melia	smeliao@netlog.com
26	Baxie Pichan	bpichanp@hhs.gov
27	Brier Overpool	boverpoolq@example.com
28	Rolland Doxsey	rdoxseyr@shareasale.com
29	Ignazio Lovitt	ilovitts@mail.ru
30	Jamill Ballintyne	jballintynet@theatlantic.com
31	Ilse Kinvig	ikinvigu@globo.com
32	Aurel Rowsell	arowsellv@patch.com
33	Chrissy Fullager	cfullagerw@howstuffworks.com
34	Brock Klimko	bklimkox@naver.com
35	Tony Gresly	tgreslyy@bbb.org
36	Pegeen Lynds	plyndsz@cdbaby.com
37	Emmalynne Lehon	elehon10@craigslist.org
38	Eugenius Corneliussen	ecorneliussen11@dailymail.co.uk
39	Tammie Axton	taxton12@cisco.com
40	Tammi Yakubovich	tyakubovich13@upenn.edu
41	Gretal Kynge	gkynge14@washingtonpost.com
42	Germayne Chagg	gchagg15@elegantthemes.com
43	Jobina Marthen	jmarthen16@parallels.com
44	Zahara Kern	zkern17@blinklist.com
45	Kimberlyn Kirwin	kkirwin18@adobe.com
46	Kalina Gemelli	kgemelli19@gmpg.org
47	Erastus Gonoude	egonoude1a@wired.com
48	Gladys Barrick	gbarrick1b@un.org
49	Sigfrid Seymour	sseymour1c@ft.com
50	Lane Soff	lsoff1d@salon.com
51	Richmond Friman	rfriman1e@spotify.com
52	Mickey Winfrey	mwinfrey1f@telegraph.co.uk
53	Zaneta Coldman	zcoldman1g@ucsd.edu
54	Jennie Boyle	jboyle1h@taobao.com
55	Jakob Librey	jlibrey1i@house.gov
56	Franklin Klemensiewicz	fklemensiewicz1j@surveymonkey.com
57	Maximilian Tomlett	mtomlett1k@example.com
58	Cobbie Renzini	crenzini1l@miitbeian.gov.cn
59	Xaviera Hardy-Piggin	xhardypiggin1m@fema.gov
60	Kaela Olenchikov	kolenchikov1n@senate.gov
61	Faye Cunnah	fcunnah1o@cbc.ca
62	Abel Bonifazio	abonifazio1p@hugedomains.com
63	Brigid Haskey	bhaskey1q@baidu.com
64	Anastassia Bartlomiejczyk	abartlomiejczyk1r@amazon.co.uk
65	Shelli Atwell	satwell1s@miitbeian.gov.cn
66	Arne Conkay	aconkay1t@purevolume.com
67	Mitzi Redwall	mredwall1u@nationalgeographic.com
68	Lyndsie Jayes	ljayes1v@oaic.gov.au
69	Nowell Beeton	nbeeton1w@linkedin.com
70	Umeko Reynoollds	ureynoollds1x@sfgate.com
71	Aeriell Standingford	astandingford1y@tripod.com
72	Quintina Casterton	qcasterton1z@illinois.edu
73	Roderigo Berthe	rberthe20@state.gov
74	Van Casbolt	vcasbolt21@toplist.cz
75	Zara Jimmes	zjimmes22@ifeng.com
76	Germana Tift	gtift23@altervista.org
77	Rivy Shortin	rshortin24@google.com.br
78	Obadias Cisneros	ocisneros25@pinterest.com
79	Jocelyne Nono	jnono26@angelfire.com
80	Kermie Edess	kedess27@goodreads.com
81	Godwin Christie	gchristie28@tinypic.com
82	Cory Straine	cstraine29@about.me
83	Desiree Brandsen	dbrandsen2a@wikispaces.com
84	Selina Dennington	sdennington2b@devhub.com
85	Gloriana Shakesbye	gshakesbye2c@vkontakte.ru
86	Elicia Plummer	eplummer2d@dailymail.co.uk
87	Davey Perren	dperren2e@ycombinator.com
88	Natalya Kilminster	nkilminster2f@amazon.co.uk
89	Ingunna Menloe	imenloe2g@artisteer.com
90	Pace Whifen	pwhifen2h@state.tx.us
91	Frederik Chang	fchang2i@harvard.edu
92	Christoph Filyashin	cfilyashin2j@umn.edu
93	Gideon Marquand	gmarquand2k@fotki.com
94	Huntley Duncanson	hduncanson2l@state.gov
95	Meier Greengrass	mgreengrass2m@guardian.co.uk
96	Boyce Dunlap	bdunlap2n@aol.com
97	Ripley Mullord	rmullord2o@slashdot.org
98	Ruperta Hancox	rhancox2p@reference.com
99	Ermengarde Pickering	epickering2q@vimeo.com
100	Oby Neame	oneame2r@sfgate.com
\.


--
-- Name: patrons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('patrons_id_seq', 100, true);


--
-- Data for Name: publishers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY publishers (id, name) FROM stdin;
1	Tusquets
2	Penguin
3	Gold Eagle
4	Aladdin Books
5	Allen & Unwin
6	SAS Publishing
7	Little, Brown
8	Viking Press
9	TokyoPop
10	Write Source
11	Bluestone Press
12	Jones and Bartlett Publishers
13	R. W. Baron
14	Thomas Nelson Publishers
15	Pinnacle Books
16	Anchor Books
17	Rowman & Littlefield Publishers
18	Harlequin
19	Coriolis Group Books
20	Harpercollins
21	Actes Sud
22	Penguin Books Ltd
23	SAS
24	Signet Classic
25	Servant Publications
26	Bounty Books
27	Self-Counsel Press
28	Hodder & Stoughton
29	Eland
30	Barney Publishing
31	Bantam Skylark Book
32	Crossway Books
33	Microsoft
34	Signet Book
35	Daw Books
36	Forge
37	Time-Life Books
38	Sweet Valley
39	St. Paul Books & Media
40	Conari Press
41	Puffin
42	Trans-Atlantic Publications
43	Zondervan Pub. House
44	HarperTrophy
45	Chapman & Hall/CRC
46	Chapman and Hall
47	Abdo Publishing Company
48	Duxbury
49	Berkeley Pub. Group
50	Harlequin Books
51	Island Books
52	Wings Books
53	West Pub. Co
54	Free Press
55	Meisha Merlin Pub
56	Springer
57	SignetBooks
58	Oxford University Press
59	Mayfield Pub Co
60	Betterway Books
61	Viking
62	HP Books
63	Morrow
64	Addison-Wesley
65	New American Library
66	Little Simon
67	R. Laffont
68	Doubleday
69	Conran Octopus Ltd
70	Troll Communications Llc
71	Santana Books,Spain
72	Norton
73	T. Nelson
74	Oxford Higher Education
75	A. Whitman
76	Diamond/Charter
77	Duxbury Press
78	Bear & Company
79	Times Books
80	Not Avail
81	WCB/McGraw-Hill
82	Fawcett
83	Bedford/St. Martin's
84	Droemersche Verlagsanstalt Th. Knaur Nachf., GmbH & Co
85	Carroll & Graf
86	Psychology Press
87	Berkley Publishing Group
88	CBN Publishing
89	Quai Voltaire
90	Dover Publications
91	University of Michigan Press
92	Harpercollins Childrens Books
93	SAGE
94	J. Countryman
95	Prentice Hall PTR
96	Vintage
97	Standard Publishing Company
98	Goldmann
99	Kensington Books
100	MIT Press
101	Hungry Minds
102	Routledge
103	University of New Mexico Press
104	Jove
105	Arbor House
106	Brooks/Cole Pub. Co
107	Golden Books
108	eReads.com
109	Princeton University Press
110	Harcourt Brace Jovanovich
111	Academic Press
112	Houghton Mifflin
113	Vantage Pr
114	Pearson/Prentice Hall
115	Wiley
116	University of North Carolina Press
117	North-Holland
118	Scribner Paperback Fiction
119	Ruminator Books
120	Bright Works Pub
121	Delacorte Press
122	Mathematical Association of America
123	Lifetime Learning Publications
124	HarperCollins Publishers
125	Andrews and McMeel
126	Avon Books
127	Broadman & Holman Pub
128	Scribner
129	Baen
130	Colegio de Lamego
131	RBA Editores
132	Watson-Guptill Publications
133	Golden Book
134	Sage Publications
135	J. Wiley
136	Smithmark Publishers
137	BBC Books
138	Yale University Press
139	New Amer Library (Mm)
140	Berkley Books
141	Warman Pub Co
142	G. P. Putnam's Sons
143	Allen & Osborne
144	Gallimard]
145	Writers Club Press
146	Z Trade Paper
147	Edward Arnold
148	Alfred A. Knopf
149	CRC Press
150	Scholastic
151	Wiley-Interscience
152	Mysterious Press/Warner Books
153	Perennial Library
154	Word Pub
155	Crown Forum
156	Tor Books
157	Gallimard
158	Bantam
159	G.P. Putnam's Sons
160	Rowohlt
161	Mira
162	Harrap
163	IEEE Press
164	CDS Books
165	Cambridge University Press
166	Random House Trade Paperbacks
167	Fawcett Crest
168	O'Reilly
169	Berkley
170	Lone Pine
171	Pocket Books
172	Harper San Francisco
173	Thomson, Brooks/Cole
174	Millbrook Press
175	Wiley & Sons
176	Plume Books
177	Wm Collins & Sons & Co
178	McGraw-Hill
179	John Wiley
180	Shambhala
181	Greenwillow Books
182	Gospel Light Pubns
183	Thorndike Press
184	HarperCollins
185	Signet
186	Harper & Row
187	Random House
188	Pocket
189	Duxbury/Thomson Learning
190	British Film Institute
191	Oak Tree Publishing (IL)
192	Here's Life Publishers
193	Abacus
194	TOR
195	PWS-KENT Pub. Co
196	Collins
197	Basic Books
198	Dell
199	Warner Books
200	Rutgers University Press
201	Adams Media Corporation
202	Droemersche Verlagsanstalt Th. Knaur Nachf. GmbH &
203	Little, Brown and Co
204	Sams Pub
205	Penguin Books
206	Tetra Press
207	Atheneum
208	University of Wisconsin Press
209	Saturday Review Press
210	Sams
211	Herald Press
212	Dutton Adult
213	GMP
214	J. P. Tarcher
215	Phoenix House
216	Kluwer Academic Publishers
217	New York Institute of Finance
218	HarperPerennial
219	Pocket Star
220	HarperPaperbacks
221	Point
222	Lippincott
223	Coach House Press
224	American Psychological Association
225	Crown Publishers
226	Bantam Doubleday Dell
227	SAS Institute
228	Addison-Wesley Publ
229	Avon
230	Wadsworth International Group
231	St. Martin's Press
232	Silhouette
233	Survey Research Center, Institute for Social Research, University of Michigan
234	REA
235	Chronicle Books
236	Chivers Audio Books
237	Three Rivers Press
238	Bantam Books
239	Editions Flammarion
240	Kensington Publishing Corporation
241	Vintage International
242	Fawcett Columbine
243	Published for Black Butterfly Children's Books by Writers and Readers Pub
244	Onyx
245	Addison Wesley
246	Prentice Hall
247	Pearson Education (US)
248	Llumina Press
249	Jones and Bartlett
250	Ballantine Books
251	H. Holt
252	Historia 16
253	Schiffer Publishing, Ltd
254	Marketplace Books, Inc
255	Love Spell
256	Methuen Publishing Ltd
257	Sage
258	Bedford/St Martins
259	Simon & Schuster
260	Penguin Studio
261	Wiley Pub
262	Random House Books for Young Readers
263	Puffin Books
264	University of Chicago Press
265	Navillus Press
266	F. Schneider
267	Que
268	Financial Times Prentice Hall
269	Chapman and Hall/CRC
270	Bantam Classics
\.


--
-- Name: publishers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('publishers_id_seq', 270, true);


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY subjects (id, name) FROM stdin;
1	inference
2	amazon_com_comics_graphic_novels_manga_shonen_boys
3	cascade_range_guidebooks
4	christian_fiction
5	securities
6	microsoft_windows_computer_file
7	intelligence_service_united_states_fiction
8	amazon_com_medicine_research_biostatistics
9	entertainment_humor_general_aas
10	amazon_com_comics_graphic_novels_manga_fantasy
11	amazon_com_literature_fiction_authors_a_z_s_saint_exupery_an
12	amazon_com_nonfiction_social_sciences_statistics
13	women_ohio_cincinnati_fiction
14	amazon_com_nonfiction_politics_political_parties
15	women_physicians_fiction
16	rhinoceroses_fiction
17	fathers_and_daughters_fiction
18	business_investing_general
19	romance_contemporary_general_aas
20	air_pilots_france_biography
21	health_mind_body_psychology_counseling_general
22	romance_contemporary
23	science_experiments_instruments_measurement_scientific_instr
24	investments
25	computers_internet_operating_systems_linux_programming
26	hashimi_rafsanjani_ali_akbar
27	psychology_industrial_humor
28	javaserver_pages
29	sociology_christian
30	riots_fiction
31	computers_internet_general
32	professional_technical_engineering_general
33	measure_theory
34	mathematical_statistics_problems_exercises_etc
35	jazz_musicians_minnesota_fiction
36	china_history_20th_century_fiction
37	science_mathematics_mathematical_analysis
38	electronic_commerce_management
39	amazon_com_professional_technical_professional_science_aaag0
40	amazon_com_computers_internet_web_development_internet_comme
41	radio_and_television_novels
42	c_computer_program_language
43	amazon_com_childrens_books_ages_9_12_general
44	public_opinion_united_states
45	nonfiction_social_sciences_sociology_general
46	betrayal_fiction
47	guggenheim_peggy_1898
48	social_sciences_research
49	amazon_com_science_fiction_fantasy_authors_a_z_c_carey_diane
50	computers_internet_programming_languages_tools_c
51	death_fiction
52	clergy
53	science_experiments_statistical_methods
54	linjr_algebra
55	educational_statistics
56	regionalism_canada_western
57	computers_internet_programming_introductory_beginning
58	interpersonal_relations
59	mathematical_statistics
60	amazon_com_science_fiction_fantasy_science_fiction_adventure
61	hiking_cascade_range_guidebooks
62	african_americans_biography
63	education
64	social_surveys_data_processing1
65	mythology_greek_juvenile_literature
66	web_site_development
67	persian_gulf_war_1991_aerial_operations_american
68	web_sites_design
69	fantastic_fiction
70	survival_analysis_biometry
71	science_fiction
72	catholic_church_doctrines
73	amazon_com_romance_authors_a_z_b_bretton_barbara
74	amazon_com_childrens_books_ages_4_8_general
75	united_states_central_intelligence_agency_aaaa1
76	estadistica_matematica_procesamiento_electronico_de_datos
77	amazon_com_science_fiction_fantasy_fantasy_general
78	children_united_states_social_conditions
79	yiddish_language_glossaries_vocabularies_etc
80	business_investing_general_aas
81	social_sciences_statistical_methods
82	saint_exupery_antoine_de_1900_1944
83	literature_fiction_genre_fiction_historical
84	amazon_com_religion_spirituality_religious_studies_history
85	amazon_com_cooking_food_wine_vegetables_vegetarian_general
86	american_literature_study_and_teaching_iran
87	history_military_aaaa1
88	research_statistical_methods
89	xhtml_document_markup_language
90	motion_picture_industry_new_york_n_y
91	working_class_writings_american
92	oceania
93	regression_analysis
94	art_collectors_united_states_biography
95	forensic_pathologists_fiction
96	cosmology_history_20th_century
97	mathematics
98	social_sciences_research_methodology
99	pastoral_fiction
100	canada_western_economic_conditions
101	amazon_com_literature_fiction_authors_a_z_c_conrad_joseph
102	child_rearing_united_states_history_miscellanea
103	amazon_com_health_mind_body_psychology_counseling_education_
104	civil_rights_movements_united_states
105	folklore_japan
106	family_policy_united_states
107	cu_chi_vietnam_quan_history
108	amazon_com_health_mind_body_psychology_counseling_research
109	visconti_luchino_1906_1976_aaaa0
110	united_states_foreign_relations_1989
111	english_language_study_and_teaching_foreign_speakers_data_pr
112	police_england_fiction
113	revenge_fiction
114	amazon_com_teens_series_young_jedi_knights
115	strategic_planning
116	poe_edgar_allan_1809_1849_in_literature
117	professional_technical_professional_science_physics_mathemat
118	jewish_women_united_states_religious_life
119	racially_mixed_people_fiction
120	amazon_com_literature_fiction_short_stories_united_states
121	teens_social_issues
122	html_document_markup_language
123	romance_regency
124	amazon_com_romance_authors_a_z_l_lawkay_susan
125	social_choice
126	amazon_com_computers_internet_certification_central_general
127	speicher_michael_scott
128	anti_communist_movements_united_states_history
129	yoga
130	amazon_com_history_asia_china_general
131	fiction_in_spanish_1945_texts
132	amazon_com_science_mathematics_applied_probability_statistic
133	computers_internet_microsoft_development_visual_basic
134	amazon_com_comics_graphic_novels_manga_shojo_girls
135	amazon_com_computers_internet_web_development_scripting_prog
136	nafisi_azar
137	linear_models_statistics_data_processing
138	stocks_charts_diagrams_etc
139	amazon_com_literature_fiction_authors_a_z_d_delillo_don
140	amazon_com_science_astronomy_cosmology
141	amazon_com_horror_authors_a_z_k_killough_lee
142	social_science
143	health
144	science_history_philosophy_general
145	work_philosophy
146	frontier_and_pioneer_life_fiction
147	family_southern_states_fiction
148	motherhood_united_states_miscellanea
149	actors_great_britain_correspondence
150	science_physics_mathematical_physics
151	amazon_com_biographies_memoirs_specific_groups_adventurers_e
152	travel_general
153	cryptographers_great_britain_biography
154	african_americans_civil_rights_juvenile_literature
155	amazon_com_computers_internet_programming_general
156	gratitude
157	social_sciences_statistics
158	gardening_miscellanea
159	social_surveys_methodology1
160	amazon_com_mystery_thrillers_authors_a_z_m_maclean_alistair
161	vietnamese_conflict_1961_1975_vietnam_cu_chi_quan
162	liberalism_united_states_history_20th_century
163	bildungsromans
164	college_stories
165	missing_children_fiction
166	computers_internet_operating_systems_general
167	amazon_com_romance_historical_general
168	hippo_extinct_city_biography
169	romance_general
170	teens
171	amazon_com_professional_technical_professional_science_aaaa6
172	professional_technical_professional_science_mathematics_pure
173	king_martin_luther_jr_1929_1968_childhood_and_youth_juvenile
174	teens_literature_fiction_classics
175	sampling_studies
176	basic_computer_program_language
177	amazon_com_health_mind_body_relationships_interpersonal_rela
178	american_literature_20th_century
179	amazon_com_cooking_food_wine_general
180	world_war_1939_1945_cryptography
181	virginia_fiction
182	high_schools_fiction
183	philosophy_modern_20th_century
184	biomedical_research_x_methods
185	talteori
186	cooking_food_wine_regional_international
187	nonfiction_philosophy_general_aas
188	estadistica_matematica_metodos_graficos
189	autobiographical_fiction
190	amazon_com_computers_internet_general
191	set_theory
192	history_asia_afghanistan
193	dictators_biography
194	statistical_methods
195	women_in_business
196	family_illinois_fiction
197	science_mathematics_pure_mathematics_calculus
198	eschatology
199	science_fiction_fantasy_science_fiction
200	xslt_computer_program_language
201	amazon_com_literature_fiction_short_stories_general
202	amazon_com_mystery_thrillers_mystery_women_sleuths
203	counting_juvenile_literature
204	drugs_nonprescription_popular_works
205	visconti_luchino_film
206	parenting_religious_aspects_christianity
207	teens_series_the_simpsons
208	multivariate_analysis
209	amazon_com_childrens_books_authors_illustrators_a_z_j_jacque
210	criminals_fiction
211	united_states_foreign_relations_20th_century
212	amazon_com_mystery_thrillers_authors_a_z_c_cornwell_patricia
213	united_states_foreign_relations_1945_1989
214	african_americans_biography_juvenile_literature
215	nuclear_nonproliferation
216	science_math_mathematics
217	rio_grande_fiction
218	mathematical_statistics_methodology
219	amazon_com_nonfiction_transportation_aviation_piloting_fligh
220	schools_fiction
221	social_systems_mathematical_models
222	microsoft_net_framework_aaaa0
223	psychology
224	literature_fiction
225	bootstrap_statistics
226	amazon_com_romance_fantasy_futuristic_ghost
227	data_mining
228	entertainment_humor_business
229	mystery_thrillers_authors_a_z_w_white_stephen
230	adventure_stories
231	nonfiction_social_sciences_statistics
232	amazon_com_mystery_thrillers_mystery_series
233	amazon_com_computers_internet_networking_networks_prot_aaaa1
234	united_states_moral_conditions
235	offices_humor
236	computers_internet_programming_languages_tools_visual_basic_
237	monte_carlo_method
238	social_surveys_congresses
239	cookery
240	khomeini_ruhollah
241	dvds
242	amazon_com_literature_fiction_authors_a_z_s_sarton_may
243	authors_french_20th_century_biography
244	literature_fiction_genre_fiction_horror
245	amazon_com_health_mind_body_exercise_fitness_yoga
246	amazon_com_comics_graphic_novels_manga_general
247	childrens_books_science_nature_how_it_works_health_diseases
248	science_mathematics_applied_probability_statistics
249	statistical_hypothesis_testing
250	world_to_1980_atlases
251	fantasy_fiction_aaaa0
252	witches_fiction
253	amazon_com_health_mind_body_diets_weight_loss_diets_healthy
254	europeans_africa_fiction
255	nonparametric_statistics
256	experimental_design
257	amazon_com_biographies_memoirs_arts_literature_authors
258	mathematical_statistics_data_processing
259	women_books_and_reading_iran
260	wilmington_n_c_fiction
261	duke_patty_1946_mental_health_aaaa0
262	amazon_com_mystery_thrillers_authors_a_z_w_wilhelm_kate
263	christian_ethics
264	amazon_com_religion_spirituality_religious_studies_science_r
265	religion_spirituality_other_practices_mysticism
266	nonfiction_social_sciences_research
267	computers_internet_computer_science_artificial_intelligence_
268	canadian_literature_20th_century
269	castro_fidel_1927
270	social_surveys
271	science_mathematics_general_aas
272	canada_western_politics_and_government
273	amazon_com_nonfiction_current_events_mass_media_media_studie
274	fiction_in_english_1945_texts
275	amazon_com_professional_technical_professional_science_aaab5
276	microsoft_visual_basic
277	science_earth_sciences_geography_general
278	authorship_handbooks_manuals_etc
279	kennedy_john_f_john_fitzgerald_1917_1963_assassination_archi
280	speculation
281	life_on_other_planets_fiction
282	women_lawyers_illinois_chicago_fiction
283	amazon_com_literature_fiction_world_literature_french
284	family_health_and_hygiene
285	romance
286	japan_fiction
287	history_world
288	romance_series_silhouette_intimate_moments
289	nonresponse_statistics
290	nonfiction_true_accounts_true_crime
291	amazon_com_childrens_books_series_fantasy_adventure_redwall
292	business_investing_investing_stocks
293	elections_united_states
294	internet_surveys
295	georgia_social_life_and_customs_humor
296	amazon_com_business_investing_general
297	state_sponsored_terrorism
298	teenage_girls_crimes_against_fiction
299	caves_juvenile_fiction
300	drugs_popular_works
301	amazon_com_mystery_thrillers_authors_a_z_h_hiaasen_carl
302	analysis_of_covariance
303	amazon_com_mystery_thrillers_mystery_general
304	suffering_fiction
305	south_carolina_history_colonial_period_ca_1600_1775_fiction
306	investment_analysis
307	education_reference
308	family_problems_fiction
309	algebras_linear
310	random_number_generators
311	judaism_united_states
312	stocks
313	amazon_com_health_mind_body_diets_weight_loss_diets_general
314	amazon_com_health_mind_body_personal_health_healthy_living
315	african_americans_fiction
316	day_trading_securities
317	amazon_com_mystery_thrillers_authors_a_z_s_soos_troy
318	amazon_com_comics_graphic_novels_manga_science_fiction
319	dh_frenta_staterna
320	manic_depressive_illness_popular_works
321	mentally_ill_children_education
322	southern_states_social_life_and_customs_1865_humor_aaaa0
323	narcotic_addicts_united_states_biography
324	united_states_social_life_and_customs_1971_fiction
325	computational_biology
326	science_mathematics
327	english_literature_study_and_teaching_iran
328	love_stories
329	amazon_com_mystery_thrillers_authors_a_z_c_cornwell_pa_aaaa0
330	amazon_com_health_mind_body_relationships_mate_seeking
331	indentured_servants_fiction
332	restaurants_california_san_francisco_bay_area_guidebooks
333	calculus_problems_exercises_etc
334	actresses_united_states_biography
335	computers_internet_operating_systems_linux_general
336	computer_programs_handbooks_manuals_etc
337	multivariat_analys
338	electronic_trading_of_securities
339	science_fiction_fantasy_fantasy_general
340	health_mind_body_psychology_counseling_neuropsychology
341	mathematical_models
342	digital_computer_simulation
343	stock_price_forecasting
344	reference_publishing_books_authorship
345	sas_computer_program
346	turner_j_m_w_joseph_mallord_william_1775_1851_themes_motives
347	literature_fiction_general_general_aas
348	amazon_com_childrens_books_animals_mice_hamsters_guinea_pigs
349	religion_spirituality_general
350	parenting_families_family_relationships_motherhood
351	amazon_com_business_investing_investing_general
352	amazon_com_medicine_general
353	baptists_united_states_clergy_biography_juvenile_literature
354	amazon_com_professional_technical_medical_research
355	angalisis_estadgistico_multivariable
356	computers_internet_software
357	report_writing_handbooks_manuals_etc
358	toys_fiction
359	stocks_data_processing
360	models_statistical
361	java_computer_program_language
362	qaddafi_muammar
363	jewish_wit_and_humor
364	medborgarrttsrrelsen_frenta_staterna
365	amazon_com_reference_education_research
366	amazon_com_business_investing_investing_introduction
367	turner_j_m_w_joseph_mallord_william_1775_1851_criticism_and_
368	amazon_com_mystery_thrillers_thrillers_spy_stories_tales_of_
369	childrens_books_literature_general
370	thomas_lowell_1892_1981
371	research
372	amazon_com_science_biological_sciences_plants_flowers
373	number_theory
374	science_general_aaaa0
375	women_england_fiction
376	science_experiments_instruments_measurement_experiments_proj
377	sampling_statistics
378	health_mind_body_psychology_counseling_developmental_psychol
379	business_investing_investing_general_aas
380	literature_fiction_contemporary
381	hazana_sailboat
382	horror_fiction
383	amazon_com_science_fiction_fantasy_authors_a_z_a_antho_aaaa0
384	manic_depressive_illness
385	orphans_fiction
386	mafia_united_states
387	amazon_com_religion_spirituality_new_age_general
388	felse_george_fictitious_character_fiction
389	country_life_ireland_fiction
390	sociologisk_metod
391	anatomy
392	surveys_methodology_technological_innovations
393	computers_technology_programming_languages_tools
394	amazon_com_computers_internet_networking_internet_groupware_
395	amazon_com_health_mind_body_psychology_counseling_statistics
396	jai_alai_betting
397	amazon_com_literature_fiction_general_literary
398	spain_civilization
399	christian_life
400	science_mathematics_general
401	romance_series_silhouette_special_edition
402	homosexuality_united_states_history_20th_century
403	methodists_fiction
404	mexican_american_border_region_fiction_aaaa0
405	erotic_literature_american
406	women_musicians_fiction
407	psychometrics
408	longitudinal_method
409	national_security_united_states
410	spain_description_and_travel
411	minnesota_fiction
412	world_war_1939_1945_secret_service_great_britain
413	surveys_methodology
414	childrens_books_literature
415	ireland_fiction
416	nightmares_fiction
417	health_surveys_statistical_methods
418	detective_and_mystery_stories
419	young_adult_fiction
420	forecasting
421	civilization_modern_philosophy
422	jews_united_states_social_life_and_customs
423	english_language_foreign_words_and_phrases_yiddish
424	amazon_com_literature_fiction_world_literature_british_aaaa7
425	united_states_politics_and_government_1945_1989
426	dogs_training_fiction
427	holistic_medicine
428	amazon_com_religion_spirituality_occult_general
429	human_anatomy
430	medicine_research_methodology1
431	english_language_rhetoric_handbooks_manuals_etc
432	female_friendship_fiction
433	business_investing_investing_options
434	social_surveys_europe
435	women_spies_united_states_fiction
436	vbscript_computer_program_language
437	questionnaires
438	amazon_com_computers_internet_microsoft_development_visual_b
439	electronic_commerce
440	amazon_com_childrens_books_arts_music_art_fashion
441	amazon_com_science_fiction_fantasy_science_fiction_general
442	statistics_problems_exercises_etc
443	laziness_folklore
444	federal_government_canada_western
445	electronic_data_processing_personnel_certification
446	amazon_com_computers_internet_certification_central_exams_mc
447	domestic_fiction
448	internet
449	reference
450	augustine_saint_bishop_of_hippo
451	amazon_com_computers_internet_networking_networks_protocols_
452	business_investing_organizational_behavior_workplace
453	science_chemistry_analytic
454	names_personal_fiction
455	ashcraft_tami_oldham_journeys
456	bioinformatics
457	authorship
458	israeloff_roberta_1952_religion
459	porcupines_fiction
460	social_sciences
461	amazon_com_childrens_books_authors_illustrators_a_z_s_soto_g
462	legal_stories
463	airplanes_fiction
464	amazon_com_religion_spirituality_occult_spiritualism
465	women_sexual_behavior_literary_collections
466	health_mind_body_exercise_fitness_pregnancy
467	xml_document_markup_language
468	amazon_com_religion_spirituality_christianity_theology_escha
469	amazon_com_cooking_food_wine_baking_desserts
470	amazon_com_childrens_books_series_science_fiction_star_aaaa1
471	hiking_oregon_guidebooks
472	science_chemistry_general_reference
473	stochastic_processes
474	hopi_indians_biography
475	xanth_imaginary_place_fiction
476	mystery_thrillers_mystery
477	sociology_research_methodology_sociology_methodology
478	amazon_com_mystery_thrillers_general
479	erotic_literature_canadian
480	amazon_com_outdoors_nature_field_guides_flowers
481	marks_leo
482	statistical_analysis
483	assad_hafez_1928
484	dogs_training
485	talayesva_don_c_b_1890
486	church_and_social_problems_united_states
487	nonfiction_social_sciences_sociology_general_aas
488	life_change_events
489	world_war_1939_1945_personal_narratives_british
490	pollifax_emily_fictitious_character_fiction
491	supervised_learning_machine_learning
492	sas_programa_de_computadora
493	geometry_analytic_problems_exercises_etc
494	amazon_com_teens_literature_fiction_general
495	eschatology_biblical_teaching
496	computers_internet_programming_general
497	home_garden_crafts_hobbies
498	amazon_com_medicine_research_general
499	amazon_com_biographies_memoirs_arts_literature_entertainers
500	reference_foreign_languages_general
501	hussein_saddam_1937
502	computer_software
503	professional_technical_engineering
504	amazon_com_childrens_books_sports_activities_cooking
505	amazon_com_childrens_books_sports_activities_activity_books_
506	probabilities
507	united_states_biography
508	amazon_com_childrens_books_literature_action_adventure
509	childrens_books_science_nature_how_it_works_environmen_aaaa0
510	amazon_com_teens_science_fiction_fantasy_science_fiction
511	trials_murder_united_states
512	amazon_com_nonfiction_politics_general
513	interpersonal_communication
514	system_design_methodology
515	amazon_com_horror_vampires
516	amazon_com_literature_fiction_general_classics
517	matrices
518	questionnaires_methodology
519	fighter_pilots_united_states_biography
520	amazon_com_literature_fiction_world_literature_united__aaaa4
521	difference_equations
522	diary_fiction
523	amazon_com_reference_writing_general
524	amazon_com_childrens_books_literature_classics_by_age_genera
525	professional_technical_professional_science_mathematics_appl
526	statistics
527	questionnaires1
528	presidents_united_states_biography_anecdotes
529	clinical_trials_statistical_methods
530	biometry
531	public_goods
532	medical_statistics1
533	nonfiction_social_sciences_anthropology_cultural
534	cookery_juvenile_literature
535	amazon_com_nonfiction_social_sciences_research
536	science_general_aas
537	tibet_china_religion
538	england_fiction
539	amazon_com_science_mathematics_pure_mathematics_calculus
540	amazon_com_horror_general
541	multivariate_analysis1
542	friendship_fiction
543	investments_computer_network_resources
544	social_values_europe
545	musical_fiction
546	social_sciences_mathematical_models
547	reference_writing_travel
548	universities_and_colleges_minnesota_fiction
549	sea_stories
550	cincinnati_ohio_fiction
551	fashion_fiction
552	amazon_com_science_astronomy_universe
553	data_interpretation_statistical1
554	psychology_statistical_methods
555	amazon_com_science_fiction_fantasy_authors_a_z_a_anthony_pie
556	united_states_social_life_and_customs_1945_1970_fiction
557	williams_kenneth_1926_correspondence
558	amazon_com_business_investing_investing_options
559	picture_books_for_children
560	amazon_com_religion_spirituality_occult_unexplained_mysterie
561	english_teachers_iran_biography
562	reference_writing_writing_skills
563	gratitude_religious_aspects_christianity
564	amazon_com_nonfiction_politics_history_theory
565	reference_resource_series
566	electronic_books
567	books_and_reading_iran
568	clerks_humor
569	cultural_property_protection_united_states
570	politics_social_sciences_politics
571	internet_surveys1
572	romance_historical
573	childrens_books_baby_3
574	congo_democratic_republic_fiction
575	world_wide_web
576	gay_men_united_states_biography
577	biographies_memoirs_arts_literature_authors
578	computers_internet_general_aas
579	biographies_memoirs_general
580	church_work_with_families_catholic_church
581	amazon_com_science_mathematics_pure_mathematics_number_theor
582	amazon_com_science_fiction_fantasy_authors_a_z_s_smith_dean_
583	amazon_com_teens_science_fiction_fantasy_fantasy
584	young_men_fiction
585	childrens_books_action_adventure
586	press_and_politics_united_states
587	vampires_fiction
588	amazon_com_childrens_books_people_places_girls_women_fiction
589	study_skills_handbooks_manuals_etc
590	entertainment_humor_self_help_psychology
591	science_fiction_fantasy
592	literature_fiction_world_literature_united_states
593	ships_employees_fiction
594	clergy_fiction
595	amazon_com_health_mind_body_psychology_counseling_general
596	home_garden_animal_care_pets_dogs
597	erotic_literature_women_authors
598	friendship_china_fiction
599	world_war_1939_1945_france_fiction
600	portfolio_management
601	professional_technical_engineering_mechanical_general
602	united_states_civilization
603	lebesgue_integral
604	methodist_church_fiction
605	politics_social_sciences_social_sciences
606	childrens_books
607	wills_maury_1932
608	amazon_com_computers_internet_digital_business_culture_proje
609	sinologists_great_britain_biography
610	linear_models_statistics
611	amazon_com_literature_fiction_general_contemporary
612	presidents_united_states_humor
613	religion_spirituality_christianity_christian_living
614	sas_computer_file
615	microsoft_visual_basic_computer_file
616	scarpetta_kay_fictitious_character_fiction
617	psychiatry_case_studies
618	caving_juvenile_fiction
619	amazon_com_science_fiction_fantasy_media_star_trek_general
620	chicago_ill_fiction
621	king_martin_luther_jr_1929_1968_childhood_and_youth
622	hopi_indians_social_life_and_customs
623	amazon_com_literature_fiction_authors_a_z_t_twain_mark_gener
624	historical_fiction
625	baseball_players_united_states_biography
626	amazon_com_computers_internet_microsoft_operating_systems_wi
627	historical_geography_maps
628	buddhism_china_tibet
629	professional_technical_engineering_chemical_materials
630	kim_chong_gil_1926
631	bridges_fiction
632	longitudinal_studies
633	election_forecasting_united_states
634	childrens_books_science_nature_how_it_works_health
635	los_angeles_dodgers_baseball_team
636	stock_exchanges
637	amazon_com_comics_graphic_novels_manga_by_publisher_tokyopop
638	estimation_theory
639	science_biological_sciences_bioinformatics
640	gambling_mathematical_models
641	computers_internet_programming_languages_tools_general
642	amazon_com_health_mind_body_exercise_fitness_general
643	romance_contemporary_general
644	bipolar_disorder_popular_works
645	gays_united_states_history_20th_century
646	art_collectors_europe_biography
647	college_teachers_minnesota_fiction
648	amazon_com_computers_internet_certification_central_pu_aaaa4
649	amazon_com_professional_technical_professional_science_mathe
650	amazon_com_science_general
651	short_stories_american
652	group_reading_iran
653	amazon_com_romance_contemporary_general
654	race_relations_fiction
655	economic_surveys
656	amazon_com_literature_fiction_genre_fiction_erotica_general
657	social_sciences_research_statistical_methods
658	amazon_com_childrens_books_literature_science_fiction_fantas
659	literature_fiction_world_literature_british_general
660	work_environment_humor
661	pregnancy_miscellanea
662	non_response_statistics
663	engineering_mathematics
664	amazon_com_biographies_memoirs_general
665	toulouse_lautrec_henri_de_1864_1901
666	social_surveys_methodology
667	numerical_analysis
668	public_opinion_polls
669	amazon_com_professional_technical_professional_science_aaah0
670	police_fiction
671	romantic_suspense_novels
672	united_states_politics_and_government_1989
673	united_states_civilization_study_and_teaching_foreign_countr
674	loss_psychology
675	professional_technical_professional_science_mathematic_aaac4
676	mexican_americans_fiction
677	bible_prophecies_eschatology
678	children_government_policy_united_states
679	man_woman_relationships_fiction
680	new_york_n_y_description_1981_guide_books_aaaa0
681	literature_fiction_general_aas
682	amazon_com_science_fiction_fantasy_fantasy_magic_wizards
683	amazon_com_religion_spirituality_religious_studies_controver
684	childrens_books_people_places_social_issues
685	butterflies_north_america_identification
686	statistical_consultants
687	amazon_com_computers_internet_certification_central_subjects
688	sampling_statistics_congresses
689	michener_james_a_james_albert_1907_1997_travel_spain
690	motion_picture_producers_and_directors_italy_biography
691	hope_psychological_aspects
692	amazon_com_business_investing_personal_finance_general
693	romance_general_aas
694	amazon_com_science_fiction_fantasy_fantasy_series_general
695	civil_rights_workers
696	visconti_luchino_1906_1976
697	science_fiction_fantasy_fantasy_general_aas
698	kidnapping_fiction
699	nonfiction_education
700	business_investing_investing_general
701	professional_technical_engineering_mechanical_general_aas
702	romance_authors_a_z_w_warren_pat
703	fantasy
704	analysis_of_variance
705	investment_analysis_aaaa0
706	vietnamese_conflict_1961_1975_tunnel_warfare
707	bestskv
708	backhouse_e_edmund_sir_1873_1944
709	europe_social_conditions_20th_century
710	population_statistical_methods
711	nonfiction_philosophy_general
712	women_lawyers_fiction
713	oregon_guidebooks
714	ohio_fiction
715	mexican_american_women_fiction
716	amazon_com_romance_general
717	fantasy_juvenile_literature
718	hailsham_of_st_marylebone_quintin_hogg_baron_1907_aaaa0
719	internet_programming
720	christian_saints_algeria_hippo_extinct_city_biography
721	encyclicals_papal
722	statistics_data_processing
723	meditations
724	amazon_com_business_investing_economics_statistics
725	mystery_fiction
726	health_mind_body_psychology_counseling_research
727	travel_specialty_travel_adventure_general
728	selling
729	computer_networks_examinations_study_guides
730	childrens_books_ages_4_8
731	computers_internet_databases_data_mining
732	science_chemistry_general_aas
733	amazon_com_literature_fiction_world_literature_united__aaaa5
734	biographies_memoirs_specific_groups_women
735	algebra
736	bullies_fiction
737	amazon_com_childrens_books_authors_illustrators_a_z_t_twain_
\.


--
-- Name: subjects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('subjects_id_seq', 737, true);


--
-- Name: authors_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authors
    ADD CONSTRAINT authors_name_key UNIQUE (name);


--
-- Name: authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: book_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_authors
    ADD CONSTRAINT book_authors_pkey PRIMARY KEY (book_id, author_id);


--
-- Name: book_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_subjects
    ADD CONSTRAINT book_subjects_pkey PRIMARY KEY (book_id, subject_id);


--
-- Name: books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: collections_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collections
    ADD CONSTRAINT collections_name_key UNIQUE (name);


--
-- Name: collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: fines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fines
    ADD CONSTRAINT fines_pkey PRIMARY KEY (id);


--
-- Name: patrons_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY patrons
    ADD CONSTRAINT patrons_email_key UNIQUE (email);


--
-- Name: patrons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY patrons
    ADD CONSTRAINT patrons_pkey PRIMARY KEY (id);


--
-- Name: publishers_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY publishers
    ADD CONSTRAINT publishers_name_key UNIQUE (name);


--
-- Name: publishers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY publishers
    ADD CONSTRAINT publishers_pkey PRIMARY KEY (id);


--
-- Name: subjects_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subjects
    ADD CONSTRAINT subjects_name_key UNIQUE (name);


--
-- Name: subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: fines_patron_id_book_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fines_patron_id_book_id_date_idx ON fines USING btree (patron_id, book_id, date);


--
-- Name: book_authors_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_authors
    ADD CONSTRAINT book_authors_author_id_fkey FOREIGN KEY (author_id) REFERENCES authors(id);


--
-- Name: book_authors_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_authors
    ADD CONSTRAINT book_authors_book_id_fkey FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: book_subjects_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_subjects
    ADD CONSTRAINT book_subjects_book_id_fkey FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: book_subjects_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_subjects
    ADD CONSTRAINT book_subjects_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES subjects(id);


--
-- Name: books_checked_out_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_checked_out_by_fkey FOREIGN KEY (checked_out_by) REFERENCES patrons(id);


--
-- Name: books_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES collections(id);


--
-- Name: books_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES publishers(id);


--
-- Name: fines_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fines
    ADD CONSTRAINT fines_book_id_fkey FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: fines_patron_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fines
    ADD CONSTRAINT fines_patron_id_fkey FOREIGN KEY (patron_id) REFERENCES patrons(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

