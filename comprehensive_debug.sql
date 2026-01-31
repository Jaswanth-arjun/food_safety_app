-- COMPREHENSIVE NOTIFICATION DEBUGGING
-- Run this in Supabase SQL Editor after sending a notification

-- 1. Check if RPC function exists and works
SELECT 'RPC Function Test' as test_name;
SELECT * FROM get_users_for_notifications('citizens') LIMIT 5;
SELECT * FROM get_users_for_notifications('inspectors') LIMIT 5;
SELECT * FROM get_users_for_notifications('both') LIMIT 5;

-- 2. Check all users and their roles
SELECT 'User Roles Check' as test_name;
SELECT id, email, full_name, role, created_at
FROM profiles
ORDER BY created_at DESC;

-- 3. Check recent notifications
SELECT 'Recent Notifications' as test_name;
SELECT n.id, n.title, n.message, n.recipient_type, n.sent_at, n.is_sent,
       p.full_name as sent_by_name, p.role as sent_by_role
FROM notifications n
LEFT JOIN profiles p ON n.sent_by = p.id
ORDER BY n.sent_at DESC
LIMIT 10;

-- 4. Check user notifications (should have records if working)
SELECT 'User Notifications Check' as test_name;
SELECT un.id, un.notification_id, un.user_id, un.is_read, un.created_at,
       p.full_name as user_name, p.role as user_role,
       n.title, n.message, n.recipient_type
FROM user_notifications un
JOIN profiles p ON un.user_id = p.id
JOIN notifications n ON un.notification_id = n.id
ORDER BY un.created_at DESC
LIMIT 20;

-- 5. Check for any RLS policy issues
SELECT 'RLS Policies Check' as test_name;
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('notifications', 'user_notifications', 'profiles')
ORDER BY tablename, policyname;

-- 6. Test direct queries (bypassing RLS for debugging)
SELECT 'Direct Query Test - Notifications' as test_name;
SELECT COUNT(*) as notification_count FROM notifications;

SELECT 'Direct Query Test - User Notifications' as test_name;
SELECT COUNT(*) as user_notification_count FROM user_notifications;

SELECT 'Direct Query Test - Profiles by Role' as test_name;
SELECT role, COUNT(*) as count FROM profiles GROUP BY role;