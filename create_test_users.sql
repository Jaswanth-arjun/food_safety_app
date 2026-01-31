-- Create test users for notification testing
-- Note: These users will need to be registered through the app normally
-- This is just to show the structure

-- Example of what the profiles should look like:
-- INSERT INTO profiles (id, email, full_name, role) VALUES
-- ('user-1-uuid', 'citizen@example.com', 'John Citizen', 'citizen'),
-- ('user-2-uuid', 'inspector@example.com', 'Jane Inspector', 'inspector');

-- To check existing users:
SELECT id, email, full_name, role FROM profiles;

-- To update a user's role (if you have existing users):
-- UPDATE profiles SET role = 'citizen' WHERE email = 'someuser@example.com';
-- UPDATE profiles SET role = 'inspector' WHERE email = 'anotheruser@example.com';