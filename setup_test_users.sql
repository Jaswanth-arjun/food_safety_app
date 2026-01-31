-- Create test users with proper roles
-- Run this in Supabase SQL Editor

-- First, check existing users
SELECT id, email, full_name, role FROM profiles;

-- Update existing users to have citizen/inspector roles
-- Replace 'existing-user-email@example.com' with real emails from your profiles table

UPDATE profiles
SET role = 'citizen'
WHERE email = 'citizen-test@example.com';  -- Replace with real email

UPDATE profiles
SET role = 'inspector'
WHERE email = 'inspector-test@example.com';  -- Replace with real email

-- Or create new test users (you'll need to register them through the app first)
-- The app registration will create profile records automatically

-- After updating roles, check the changes
SELECT id, email, full_name, role FROM profiles WHERE role IN ('citizen', 'inspector');