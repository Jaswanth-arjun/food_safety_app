-- Check existing users and their roles
SELECT id, email, full_name, role, created_at
FROM profiles
ORDER BY created_at DESC;

-- Check if there are any users with citizen or inspector roles
SELECT role, COUNT(*) as count
FROM profiles
GROUP BY role;

-- Check recent notifications
SELECT n.id, n.title, n.message, n.recipient_type, n.sent_at, p.full_name as sent_by
FROM notifications n
LEFT JOIN profiles p ON n.sent_by = p.id
ORDER BY n.sent_at DESC
LIMIT 5;

-- Check user notifications
SELECT un.id, un.user_id, p.full_name, un.is_read, un.created_at, n.title, n.message
FROM user_notifications un
JOIN profiles p ON un.user_id = p.id
JOIN notifications n ON un.notification_id = n.id
ORDER BY un.created_at DESC
LIMIT 10;