/*
  Triggers
*/

create or replace trigger BIKES_BRIU
  before insert or update
  on BIKES
  for each row
declare
  cnt number;
begin
  /*
   This trigger checks if a bike isn't both occupied and attached to a terminal.
   If it is, application error -20002 is raised.
 */
  if :new.OCCUPIED = 'Y' then
    select count(*) into cnt from TERMINALS where TERMINALS.BIKE_ID = :new.BIKE_ID;
    if cnt > 0 then
      RAISE_APPLICATION_ERROR(-20002, 'Bike cannot be both occupied and attached to a terminal.');
    end if;
  end if;
end;
/

create or replace trigger TERMINALS_BRIU
  before insert or update
  on TERMINALS
  for each row
declare
  cnt number;
begin
  /*
    This trigger checks if a bike isn't both occupied and attached to a terminal.
    If it is, application error -20002 is raised.
  */
  if :new.BIKE_ID is not null then
    select count(*) into cnt from BIKES where BIKES.BIKE_ID = :new.BIKE_ID and BIKES.OCCUPIED = 'Y';
    if cnt > 0 then
      RAISE_APPLICATION_ERROR(-20002, 'Bike cannot be both occupied and attached to a terminal.');
    end if;
  end if;
end;
/

create or replace trigger HIRES_BRIU
  before insert or update
  on HIRES
  for each row
declare
  cnt number;
begin
  /*
    This trigger checks if the same bike wasn't hired twice during a certain period of time.
    If it is, application error -20000 is raised.

    It also checks if start time isn't later than the end time of a hire.
    If it is, application error -20001 is raised.
  */

  cnt := 0;

  if (:new.END_TIME is null) then
    select count(*) into cnt
    from HIRES
    where :new.BIKE_ID = BIKE_ID
      AND :new.START_TIME < END_TIME;
  else
    if :new.END_TIME < :new.START_TIME then
      RAISE_APPLICATION_ERROR(-20000, 'START_TIME cannot be later than END_TIME.');
    end if;

    select count(*) into cnt
    from HIRES
    where :new.HIRE_ID != HIRE_ID
      and :new.BIKE_ID = BIKE_ID
      and (:new.START_TIME < END_TIME or :new.END_TIME > START_TIME);
  end if;

  if cnt > 0 then
    RAISE_APPLICATION_ERROR(-20001,
                            'Invalid START_TIME and END_TIME for a row in table HIRES ' ||
                            '(time ranges for the same bike cannot overlap).');
  end if;
end;
/

/*
  Procedures
*/

create or replace procedure hire_bike(hire_bike_id in number, hire_user_id in number) is
  hire_price number(6, 2);
  user_money number(6, 2);
  user_exists number(1);
  bike_exists number(1);
  bike_occupied CHAR(1);
begin
  -- check if user and bike exist
  select count(*) into user_exists from USERS where user_id = hire_user_id;
  select count(*) into bike_exists from BIKES where bike_id = hire_bike_id;
  if user_exists = 0 or bike_exists = 0 then
    raise_application_error(-20003, 'User or bike for a given ID does not exist');
  end if;

  -- check if bike isn't already occupied
  select occupied into bike_occupied from bikes where bike_id = hire_bike_id;
  if bike_occupied = 'Y' then
    raise_application_error(-20004, 'This bike is already occupied');
  end if;

  -- check user's balance against price
  select balance into user_money from USERS where USER_ID = hire_user_id;
  select BIKE_TYPE_PRICING.price into hire_price
  from BIKES
         inner join BIKE_TYPE_PRICING on BIKES.TYPE = BIKE_TYPE_PRICING.BIKE_TYPE
  where BIKES.BIKE_ID = hire_bike_id;
  if user_money < hire_price then
    raise_application_error(-20005, 'Not enough money to hire');
  end if;

  -- bike can be hired
  insert into hires values (NULL, hire_bike_id, hire_user_id, sysdate, NULL, hire_price, NULL);
  update USERS set balance = balance - hire_price;
end;
/
