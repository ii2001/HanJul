create table public.analytics_events (
  id bigint generated always as identity primary key,
  event_name text not null check (event_name in ('app_open', 'favorite_toggle', 'notification_toggle')),
  app_version text not null check (char_length(app_version) between 1 and 32),
  platform text not null default 'macOS' check (platform = 'macOS'),
  created_at timestamptz not null default now()
);

alter table public.analytics_events enable row level security;

revoke all on table public.analytics_events from anon, authenticated;
grant insert on table public.analytics_events to anon;
grant usage, select on sequence public.analytics_events_id_seq to anon;

create policy "anon may insert allowlisted analytics events"
on public.analytics_events
for insert
to anon
with check (
  event_name in ('app_open', 'favorite_toggle', 'notification_toggle')
  and char_length(app_version) between 1 and 32
  and platform = 'macOS'
);
