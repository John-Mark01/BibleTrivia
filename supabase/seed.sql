-- Sample content for local/dev branches. Not applied to production.

insert into public.topics (id, name) overriding system value values
    (1, 'Genesis'),
    (2, 'The Life of Jesus'),
    (3, 'Acts & Paul'),
    (4, 'Kings & Prophets');

insert into public.quizzes (id, name, topic_id, difficulty, total_points, time_to_complete) overriding system value values
    (1, 'In the Beginning', 1, 0, 50, 2),
    (2, 'Abraham''s Journey', 1, 1, 60, 3),
    (3, 'Birth of Jesus', 2, 0, 50, 2),
    (4, 'Miracles', 2, 1, 60, 3),
    (5, 'Paul''s Travels', 3, 2, 80, 4),
    (6, 'Elijah', 4, 2, 80, 3);

insert into public.questions (id, quiz_id, position, text, explanation) overriding system value values
    (1, 1, 1, 'On which day did God create light', 'Genesis 1:3-5 — light was created on the first day.'),
    (2, 1, 2, 'What was the name of the garden God planted', 'Genesis 2:8 — the Garden of Eden.'),
    (3, 1, 3, 'Who was the first son of Adam and Eve', 'Genesis 4:1 — Cain was born first.'),
    (4, 2, 1, 'What was Abraham''s original name', 'Genesis 17:5 — Abram was renamed Abraham.'),
    (5, 2, 2, 'What was the name of Abraham''s wife', 'Genesis 17:15 — Sarai, renamed Sarah.'),
    (6, 2, 3, 'Which son did God ask Abraham to offer', 'Genesis 22:2 — Isaac.'),
    (7, 3, 1, 'In which town was Jesus born', 'Luke 2:4-7 — Bethlehem.'),
    (8, 3, 2, 'Who ruled Judea when Jesus was born', 'Matthew 2:1 — King Herod.'),
    (9, 3, 3, 'Where did Mary lay the baby Jesus', 'Luke 2:7 — in a manger.'),
    (10, 4, 1, 'What was Jesus'' first recorded miracle', 'John 2:1-11 — water into wine at Cana.'),
    (11, 4, 2, 'How many loaves fed the five thousand', 'Matthew 14:17 — five loaves and two fish.'),
    (12, 4, 3, 'Whom did Jesus raise after four days in the tomb', 'John 11 — Lazarus.'),
    (13, 5, 1, 'On which island was Paul shipwrecked', 'Acts 28:1 — Malta.'),
    (14, 5, 2, 'On the road to which city was Saul converted', 'Acts 9:3 — Damascus.'),
    (15, 5, 3, 'Who travelled with Paul on his first missionary journey', 'Acts 13:2 — Barnabas.'),
    (16, 6, 1, 'Which birds fed Elijah by the brook', '1 Kings 17:6 — ravens.'),
    (17, 6, 2, 'On which mountain did Elijah face the prophets of Baal', '1 Kings 18:19 — Mount Carmel.'),
    (18, 6, 3, 'How was Elijah taken up to heaven', '2 Kings 2:11 — in a whirlwind.');

insert into public.answers (question_id, text, is_correct) values
    (1, 'The first day', true), (1, 'The third day', false), (1, 'The fourth day', false), (1, 'The seventh day', false),
    (2, 'Eden', true), (2, 'Gethsemane', false), (2, 'Babylon', false), (2, 'Canaan', false),
    (3, 'Cain', true), (3, 'Abel', false), (3, 'Seth', false), (3, 'Enoch', false),
    (4, 'Abram', true), (4, 'Israel', false), (4, 'Terah', false), (4, 'Lot', false),
    (5, 'Sarah', true), (5, 'Rebekah', false), (5, 'Rachel', false), (5, 'Leah', false),
    (6, 'Isaac', true), (6, 'Ishmael', false), (6, 'Jacob', false), (6, 'Esau', false),
    (7, 'Bethlehem', true), (7, 'Nazareth', false), (7, 'Jerusalem', false), (7, 'Capernaum', false),
    (8, 'Herod', true), (8, 'Pilate', false), (8, 'Caesar Augustus', false), (8, 'Caiaphas', false),
    (9, 'In a manger', true), (9, 'In a cradle', false), (9, 'In the temple', false), (9, 'In a boat', false),
    (10, 'Turning water into wine', true), (10, 'Walking on water', false), (10, 'Healing a blind man', false), (10, 'Calming the storm', false),
    (11, 'Five', true), (11, 'Seven', false), (11, 'Twelve', false), (11, 'Two', false),
    (12, 'Lazarus', true), (12, 'Jairus'' daughter', false), (12, 'Peter', false), (12, 'John the Baptist', false),
    (13, 'Malta', true), (13, 'Cyprus', false), (13, 'Crete', false), (13, 'Patmos', false),
    (14, 'Damascus', true), (14, 'Jerusalem', false), (14, 'Antioch', false), (14, 'Rome', false),
    (15, 'Barnabas', true), (15, 'Silas', false), (15, 'Timothy', false), (15, 'Luke', false),
    (16, 'Ravens', true), (16, 'Doves', false), (16, 'Eagles', false), (16, 'Sparrows', false),
    (17, 'Mount Carmel', true), (17, 'Mount Sinai', false), (17, 'Mount Zion', false), (17, 'Mount of Olives', false),
    (18, 'In a whirlwind', true), (18, 'On a cloud', false), (18, 'Up a ladder', false), (18, 'He was not taken up', false);

select setval(pg_get_serial_sequence('public.topics', 'id'), (select max(id) from public.topics));
select setval(pg_get_serial_sequence('public.quizzes', 'id'), (select max(id) from public.quizzes));
select setval(pg_get_serial_sequence('public.questions', 'id'), (select max(id) from public.questions));
