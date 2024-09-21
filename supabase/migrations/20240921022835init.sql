-- Create a trigger to update the driver status
create function update_driver_status() returns trigger language plpgsql as $ $ begin if new.status = 'completed' then
update
  public.drivers
set
  is_available = true
where
  id = new.driver_id;

else
update
  public.drivers
set
  is_available = false
where
  id = new.driver_id;

end if;

return new;

end $ $;

create trigger driver_status_update_trigger
after
insert
  or
update
  on rides for each row execute function update_driver_status();

-- Finds the closest available driver within 3000m radius
create function public.find_driver(
  origin geography(POINT),
  destination geography(POINT),
  fare int
) returns table(driver_id uuid, ride_id uuid) language plpgsql as $ $ declare v_driver_id uuid;

v_ride_id uuid;

begin
select
  drivers.id into v_driver_id
from
  public.drivers
where
  is_available = true
  and st_dwithin(origin, location, 3000)
order by
  drivers.location < -> origin
limit
  1;

-- return null if no available driver is found
if v_driver_id is null then return;

end if;

insert into
  public.rides (
    driver_id,
    passenger_id,
    origin,
    destination,
    fare
  )
values
  (
    v_driver_id,
    auth.uid(),
    origin,
    destination,
    fare
  ) returning id into v_ride_id;

return query
select
  v_driver_id as driver_id,
  v_ride_id as ride_id;

end $ $ security definer;