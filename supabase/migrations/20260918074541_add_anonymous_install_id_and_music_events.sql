alter table public.analytics_events
  add column anonymous_install_id uuid;

alter table public.analytics_events
  drop constraint if exists analytics_events_event_name_check;

alter table public.analytics_events
  add constraint analytics_events_event_name_check
  check (event_name in ('app_open', 'favorite_toggle', 'notification_toggle', 'music_play', 'music_pause'));

drop policy if exists "anon may insert allowlisted analytics events"
on public.analytics_events;

create policy "anon may insert allowlisted analytics events"
on public.analytics_events
for insert
to anon
with check (
  event_name in ('app_open', 'favorite_toggle', 'notification_toggle', 'music_play', 'music_pause')
  and char_length(app_version) between 1 and 32
  and platform = 'macOS'
  and anonymous_install_id is not null
);
