# Small Hotel Manager — Normalized Cloud Version

## Features
- Supabase email/password login; each account has isolated data through RLS.
- Normalized cloud tables: customers, invoices, invoice_items, expenses, payments, hotel_settings.
- Hotel Settings for hotel name, logo (URL or small uploaded image), GSTIN, FSSAI number, Instagram link, address, phone/email and contact/footer details.
- Settings are stored in the hotel's `hotel_settings` row and appear on invoices.
- GST rate remains manual per invoice; no default GST rate.
- Mobile-friendly UI and end-of-day customer/invoice reports.

## Supabase setup
1. Run `supabase_schema.sql` once in Supabase SQL Editor.
2. The browser-safe Supabase URL and publishable key are already configured in `config.js` for the connected project.
3. Keep Row Level Security enabled. Do not replace the publishable key with a service-role/secret key.
4. Existing `hotel_data` is retained for optional legacy migration.

## Hotel Settings
After login, open **🏨 Hotel Settings** and enter the hotel's details. You can paste a public logo URL or upload a small PNG/JPG logo (under 700 KB). Save to sync the settings to the cloud.


## Fixed client branding
Samudhra Foods branding (name, logo, phone +91 81222 17228 and Instagram handle @SAMUDHRAFOODS) is embedded in the webpage assets and is not written to localStorage or Supabase hotel data. The supplied Instagram QR image is also bundled as a static webpage asset.
