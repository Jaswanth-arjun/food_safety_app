-- Test the RPC function directly
-- Run this in Supabase SQL Editor

-- Test the function with different parameters
SELECT * FROM get_users_for_notifications('citizens');
SELECT * FROM get_users_for_notifications('inspectors');
SELECT * FROM get_users_for_notifications('both');

-- Check what users exist
SELECT id, email, full_name, role FROM profiles;

-- Check recent notifications
SELECT n.id, n.title, n.message, n.recipient_type, n.sent_at,
       p.full_name as sent_by
FROM notifications n
LEFT JOIN profiles p ON n.sent_by = p.id
ORDER BY n.sent_at DESC
LIMIT 5;

-- Check user notifications
SELECT un.id, un.notification_id, un.user_id, un.is_read,
       p.full_name as user_name, n.title, n.message
FROM user_notifications un
JOIN profiles p ON un.user_id = p.id
JOIN notifications n ON un.notification_id = n.id
ORDER BY un.created_at DESC
LIMIT 10;