-- ===========================================
-- NOTIFICATIONS TABLES SETUP
-- Run this in your Supabase SQL Editor
-- ===========================================

-- Enable UUID extension (if not already enabled)
create extension if not exists "uuid-ossp";

-- Create notifications table
create table if not exists notifications (
  id uuid default uuid_generate_v4(),
  title text,
  message text not null,
  recipient_type text not null check (recipient_type in ('citizens', 'inspectors', 'both')),
  sent_by uuid references profiles(id) on delete set null,
  created_at timestamptz default now(),
  sent_at timestamptz,
  is_sent boolean default false,
  primary key (id)
);

-- Create user_notifications table
create table if not exists user_notifications (
  id uuid default uuid_generate_v4(),
  notification_id uuid references notifications(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  is_read boolean default false,
  read_at timestamptz,
  created_at timestamptz default now(),
  primary key (id),
  unique(notification_id, user_id)
);

-- Enable RLS
alter table notifications enable row level security;
alter table user_notifications enable row level security;

-- Create policies for notifications table
create policy "Admins can manage notifications" on notifications
  for all using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

create policy "Users can view notifications they received" on notifications
  for select using (
    exists (select 1 from user_notifications un where un.notification_id = notifications.id and un.user_id = auth.uid())
  );

-- Create policies for user_notifications table
create policy "Users can view notifications sent to them" on user_notifications
  for select using (
    user_id = auth.uid()
  );

create policy "Admins can manage user notifications" on user_notifications
  for all using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

-- Create a security definer function for admins to get user profiles for notifications
create or replace function get_users_for_notifications(recipient_type text)
returns table(id uuid, full_name text, role text)
language sql
security definer
set search_path = public
as $$
  select p.id, p.full_name, p.role
  from profiles p
  where
    case
      when recipient_type = 'citizens' then p.role = 'citizen'
      when recipient_type = 'inspectors' then p.role = 'inspector'
      when recipient_type = 'both' then p.role in ('citizen', 'inspector')
      else false
    end;
$$;

-- Grant execute permission to authenticated users
grant execute on function get_users_for_notifications(text) to authenticated;

-- Update the notification provider to use this function instead of direct query

-- Create indexes for performance
create index if not exists idx_notifications_sent_by on notifications(sent_by);
create index if not exists idx_notifications_recipient_type on notifications(recipient_type);
create index if not exists idx_notifications_created_at on notifications(created_at desc);
create index if not exists idx_notifications_is_sent on notifications(is_sent);

create index if not exists idx_user_notifications_user_id on user_notifications(user_id);
create index if not exists idx_user_notifications_notification_id on user_notifications(notification_id);
create index if not exists idx_user_notifications_is_read on user_notifications(is_read);
create index if not exists idx_user_notifications_created_at on user_notifications(created_at desc);