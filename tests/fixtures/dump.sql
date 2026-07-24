drop table if exists hako_restore_fixture;

create table hako_restore_fixture (
  id integer primary key,
  label text not null
);

insert into hako_restore_fixture (id, label) values
  (1, 'alpha'),
  (2, 'bravo'),
  (3, 'charlie');
