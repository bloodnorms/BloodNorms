-- ============================================================================
-- BloodNorms | 0003_storage.sql
-- Storage buckets for doctor's slips and donor verification documents
-- ============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('slips', 'slips', false, 5242880, array['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
  ('donor-docs', 'donor-docs', false, 5242880, array['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
on conflict (id) do update set
  public = false,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];

-- RLS on storage.objects
create policy "slips_requester_upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'slips' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "slips_requester_read" on storage.objects
  for select to authenticated
  using (bucket_id = 'slips' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

create policy "donor_docs_upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'donor-docs' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "donor_docs_read" on storage.objects
  for select to authenticated
  using (bucket_id = 'donor-docs' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

