JASHxp Game Portfolio — Supabase shared database setup
======================================================

FILES
- index.html: the website, configured with your Supabase Project URL and publishable key.
- supabase-setup.sql: database schema, row-level security, initial 20 games, and realtime setup.

SETUP
1. Open https://supabase.com/dashboard and select project axfgsupxprcnlpmaaxij.
2. Go to SQL Editor > New query.
3. Open supabase-setup.sql, copy all its contents, paste into the SQL Editor, and Run.
4. Go to Authentication > Users > Add user. Create your admin user with your email and a strong password. If email confirmation is enabled, confirm the account as directed by Supabase.
5. Copy the new user's UUID from Authentication > Users.
6. In SQL Editor, run this statement after replacing the example UUID with your actual user's UUID:

   insert into public.admin_users (user_id)
   values ('YOUR_AUTH_USER_UUID')
   on conflict do nothing;

7. Upload index.html to the root of your GitHub Pages repository (replace the previous index.html). You may keep README.txt and supabase-setup.sql in the repo, but don't need to publish them for the site to work.
8. Open your website, click Admin sign in, and sign in with the Supabase user you created.

HOW IT WORKS
- Everyone can read the public game list.
- Only the user whose Auth UUID is listed in public.admin_users can add, edit, change status, or delete games.
- Visitors receive live updates through Supabase Realtime; refreshing the page also reloads the shared database.
- Game logos, cover image URLs, statuses, and multiple resource links are stored in the database.

SECURITY NOTES
- The Supabase publishable key in index.html is intended for browser use. Database security is enforced by Row Level Security policies, not by hiding this key.
- Never put a service_role key, secret API key, or database password in index.html or GitHub.
- Do not add public users to public.admin_users. Only add your own trusted admin UUID using the Supabase SQL Editor.
- This setup provides admin email/password sign-in. Use a strong, unique password and enable appropriate account security in Supabase.

TROUBLESHOOTING
- If the site says “Database setup needed”, make sure supabase-setup.sql ran successfully in the correct project and the Project URL/key in index.html match that project.
- If sign-in succeeds but editing is not enabled, check that the exact Auth user's UUID exists in public.admin_users.
- If edits save but visitors don't update immediately, confirm the games table is included in the supabase_realtime publication; a page refresh should still load current data.
