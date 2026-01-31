-- ===========================================
-- FOOD SAFETY APP DATABASE SCHEMA
-- ===========================================
-- Run this SQL in your Supabase SQL Editor
-- https://supabase.com/dashboard/project/YOUR_PROJECT/sql

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ===========================================
-- 1. PROFILES TABLE (User Management)
-- ===========================================

create table profiles (
  id uuid references auth.users(id) on delete cascade,
  email text unique not null,
  full_name text not null,
  phone text,
  role text default 'citizen' check (role in ('citizen', 'inspector', 'admin')),
  department text,
  license_number text,
  organization text,
  profile_image_url text,
  is_active boolean default true,
  is_verified boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  primary key (id)
);

-- ===========================================
-- 2. RESTAURANTS TABLE
-- ===========================================

create table restaurants (
  id uuid default uuid_generate_v4(),
  name text not null,
  address text not null,
  phone text,
  email text,
  license_number text unique,
  cuisine_type text,
  owner_name text,
  capacity integer,
  operating_hours jsonb,
  latitude decimal(10,8),
  longitude decimal(11,8),
  average_rating decimal(3,2) default 0,
  total_reviews integer default 0,
  risk_level text default 'low' check (risk_level in ('low', 'medium', 'high', 'critical')),
  last_inspection_date timestamptz,
  next_inspection_due timestamptz,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  primary key (id)
);

-- ===========================================
-- 3. REPORTS TABLE (Citizen Reports)
-- ===========================================

create table reports (
  id uuid default uuid_generate_v4(),
  citizen_id uuid references profiles(id) on delete cascade,
  restaurant_id uuid references restaurants(id) on delete set null,
  title text not null,
  description text not null,
  category text not null check (category in ('hygiene', 'food_quality', 'pest_control', 'temperature', 'documentation', 'other')),
  severity text default 'medium' check (severity in ('low', 'medium', 'high', 'critical')),
  status text default 'pending' check (status in ('pending', 'investigating', 'resolved', 'rejected')),
  location jsonb,
  images text[],
  is_anonymous boolean default false,
  assigned_inspector_id uuid references profiles(id),
  inspector_notes text,
  resolution text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  resolved_at timestamptz,
  primary key (id)
);

-- ===========================================
-- 4. INSPECTIONS TABLE
-- ===========================================

create table inspections (
  id uuid default uuid_generate_v4(),
  inspector_id uuid references profiles(id) on delete cascade,
  restaurant_id uuid references restaurants(id) on delete cascade,
  report_id uuid references reports(id) on delete set null,
  inspection_date timestamptz default now(),
  status text default 'in_progress' check (status in ('scheduled', 'in_progress', 'completed', 'cancelled')),
  checklist jsonb,
  overall_score integer check (overall_score >= 0 and overall_score <= 100),
  risk_level text check (risk_level in ('low', 'medium', 'high', 'critical')),
  findings text,
  recommendations text,
  images text[],
  compliance_status text default 'pending' check (compliance_status in ('compliant', 'non_compliant', 'pending')),
  follow_up_required boolean default false,
  follow_up_date timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  primary key (id)
);

-- ===========================================
-- 5. RATINGS TABLE (Restaurant Reviews)
-- ===========================================

create table ratings (
  id uuid default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  restaurant_id uuid references restaurants(id) on delete cascade,
  rating integer not null check (rating >= 1 and rating <= 5),
  review_text text,
  visit_date date,
  would_recommend boolean,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  primary key (id),
  unique (user_id, restaurant_id) -- One rating per user per restaurant
);

-- ===========================================
-- 6. ACTIVITIES TABLE (Audit Log)
-- ===========================================

create table activities (
  id uuid default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete set null,
  action_type text not null,
  entity_type text not null,
  entity_id uuid,
  description text,
  metadata jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz default now(),
  primary key (id)
);

-- ===========================================
-- ENABLE ROW LEVEL SECURITY
-- ===========================================

alter table profiles enable row level security;
alter table restaurants enable row level security;
alter table reports enable row level security;
alter table inspections enable row level security;
alter table ratings enable row level security;
alter table activities enable row level security;

-- ===========================================
-- ROW LEVEL SECURITY POLICIES
-- ===========================================

-- PROFILES POLICIES
create policy "Users can view their own profile" on profiles
  for select using (auth.uid() = id);

create policy "Users can update their own profile" on profiles
  for update using (auth.uid() = id);

create policy "Users can insert their own profile" on profiles
  for insert with check (auth.uid() = id);

create policy "Admins can view all profiles" on profiles
  for select using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

create policy "Admins can update all profiles" on profiles
  for update using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

-- RESTAURANTS POLICIES
create policy "Anyone can view active restaurants" on restaurants
  for select using (is_active = true);

create policy "Inspectors and admins can manage restaurants" on restaurants
  for all using (
    exists (select 1 from profiles where id = auth.uid() and role in ('inspector', 'admin'))
  );

-- REPORTS POLICIES
create policy "Users can view their own reports" on reports
  for select using (auth.uid() = citizen_id);

create policy "Users can create reports" on reports
  for insert with check (auth.uid() = citizen_id);

create policy "Users can update their own reports" on reports
  for update using (auth.uid() = citizen_id);

create policy "Inspectors can view and update assigned reports" on reports
  for select using (
    exists (select 1 from profiles where id = auth.uid() and role in ('inspector', 'admin'))
  );

create policy "Inspectors can update assigned reports" on reports
  for update using (
    exists (select 1 from profiles where id = auth.uid() and role in ('inspector', 'admin'))
  );

-- INSPECTIONS POLICIES
create policy "Inspectors can view their own inspections" on inspections
  for select using (auth.uid() = inspector_id);

create policy "Inspectors can create inspections" on inspections
  for insert with check (auth.uid() = inspector_id);

create policy "Inspectors can update their own inspections" on inspections
  for update using (auth.uid() = inspector_id);

create policy "Admins can view all inspections" on inspections
  for select using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

-- RATINGS POLICIES
create policy "Anyone can view ratings" on ratings
  for select using (true);

create policy "Authenticated users can create ratings" on ratings
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own ratings" on ratings
  for update using (auth.uid() = user_id);

create policy "Users can delete their own ratings" on ratings
  for delete using (auth.uid() = user_id);

-- ACTIVITIES POLICIES
create policy "Admins can view all activities" on activities
  for select using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

create policy "Users can view their own activities" on activities
  for select using (auth.uid() = user_id);

create policy "System can insert activities" on activities
  for insert with check (true);

-- ===========================================
-- FUNCTIONS & TRIGGERS
-- ===========================================

-- Function to update restaurant ratings
create or replace function update_restaurant_rating()
returns trigger as $$
begin
  update restaurants
  set
    average_rating = (
      select coalesce(avg(rating), 0)
      from ratings
      where restaurant_id = coalesce(NEW.restaurant_id, OLD.restaurant_id)
    ),
    total_reviews = (
      select count(*)
      from ratings
      where restaurant_id = coalesce(NEW.restaurant_id, OLD.restaurant_id)
    ),
    updated_at = now()
  where id = coalesce(NEW.restaurant_id, OLD.restaurant_id);

  return coalesce(NEW, OLD);
end;
$$ language plpgsql;

-- Trigger for rating updates
create trigger update_restaurant_rating_trigger
  after insert or update or delete on ratings
  for each row execute function update_restaurant_rating();

-- Function to update updated_at timestamp
create or replace function update_updated_at_column()
returns trigger as $$
begin
  NEW.updated_at = now();
  return NEW;
end;
$$ language plpgsql;

-- Add updated_at triggers to relevant tables
create trigger update_profiles_updated_at before update on profiles
  for each row execute function update_updated_at_column();

create trigger update_restaurants_updated_at before update on restaurants
  for each row execute function update_updated_at_column();

create trigger update_reports_updated_at before update on reports
  for each row execute function update_updated_at_column();

create trigger update_inspections_updated_at before update on inspections
  for each row execute function update_updated_at_column();

create trigger update_ratings_updated_at before update on ratings
  for each row execute function update_updated_at_column();

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================

create index idx_profiles_email on profiles(email);
create index idx_profiles_role on profiles(role);
create index idx_profiles_is_verified on profiles(is_verified);
create index idx_profiles_is_active on profiles(is_active);

create index idx_restaurants_location on restaurants using gist (point(longitude, latitude));
create index idx_restaurants_risk_level on restaurants(risk_level);
create index idx_restaurants_is_active on restaurants(is_active);

create index idx_reports_citizen_id on reports(citizen_id);
create index idx_reports_restaurant_id on reports(restaurant_id);
create index idx_reports_status on reports(status);
create index idx_reports_assigned_inspector on reports(assigned_inspector_id);

create index idx_inspections_inspector_id on inspections(inspector_id);
create index idx_inspections_restaurant_id on inspections(restaurant_id);
create index idx_inspections_status on inspections(status);

create index idx_ratings_restaurant_id on ratings(restaurant_id);
create index idx_ratings_user_id on ratings(user_id);

create index idx_activities_user_id on activities(user_id);
create index idx_activities_entity on activities(entity_type, entity_id);
create index idx_activities_created_at on activities(created_at desc);

-- ===========================================
-- INITIAL DATA (Optional)
-- ===========================================

-- Insert some sample restaurants (optional)
insert into restaurants (name, address, phone, cuisine_type, latitude, longitude) values
('Tasty Bites Restaurant', '123 Main Street, City Center', '+91-9876543210', 'Indian', 28.6139, 77.2090),
('Healthy Eats Cafe', '456 Park Avenue, Downtown', '+91-9876543211', 'Healthy', 28.7041, 77.1025),
('Spice Garden', '789 Food Street, Market Area', '+91-9876543212', 'Indian', 28.5355, 77.3910);

-- ===========================================
-- COMPLETE! DATABASE SCHEMA READY
-- ===========================================