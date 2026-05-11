-- Migration to ensure the 'images' bucket is public and has correct policies

-- 1. Ensure the bucket exists and is public
insert into storage.buckets (id, name, public)
values ('images', 'images', true)
on conflict (id) do update
set public = true;

-- 2. Allow public (anonymous) access to read files in the 'images' bucket
create policy "Public Access to Images"
on storage.objects for select
using ( bucket_id = 'images' );
