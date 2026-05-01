/**
 * Types Supabase générés à la main pour Phase 1.
 * À remplacer par `supabase gen types typescript` une fois le projet lié.
 */

export type UserRole = 'client' | 'provider' | 'owner' | 'admin';

export type AssetCategory =
  | 'vehicle'
  | 'boat'
  | 'property'
  | 'equipment'
  | 'tool'
  | 'event';

export type AssetStatus =
  | 'available'
  | 'occupied'
  | 'cleaning'
  | 'unavailable';

export type ServiceType = 'taxi' | 'minibus' | 'boat' | 'truck';

export type TransactionStatus =
  | 'pending'
  | 'confirmed'
  | 'completed'
  | 'cancelled'
  | 'disputed';

export type BookingStatus =
  | 'pending'
  | 'confirmed'
  | 'active'
  | 'completed'
  | 'cancelled'
  | 'disputed';

export interface UserRow {
  id: string;
  auth_user_id: string | null;
  email: string | null;
  phone: string | null;
  full_name: string | null;
  avatar_url: string | null;
  role: UserRole;
  stripe_customer_id: string | null;
  created_at: string;
}

export interface ProviderRow {
  id: string;
  user_id: string;
  service_type: ServiceType | null;
  vehicle_name: string | null;
  vehicle_photo_url: string | null;
  id_doc_url: string | null;
  license_url: string | null;
  verified: boolean;
  stripe_account_id: string | null;
  qr_code_data: string | null;
  base_rate: number | null;
  is_available: boolean;
  current_lat: number | null;
  current_lng: number | null;
  created_at: string;
}

export interface AssetRow {
  id: string;
  owner_id: string;
  category: AssetCategory | null;
  name: string | null;
  description: string | null;
  photos: string[] | null;
  hourly_rate: number | null;
  daily_rate: number | null;
  weekly_rate: number | null;
  deposit_amount: number | null;
  min_duration_hours: number;
  cleaning_duration_minutes: number;
  status: AssetStatus;
  available_from: string | null;
  lat: number | null;
  lng: number | null;
  address: string | null;
  ttlock_lock_id: string | null;
  shelly_device_id: string | null;
  nfc_card_ids: string[] | null;
  access_instructions: string | null;
  stripe_account_id: string | null;
  verified: boolean;
  created_at: string;
}

export interface BookingRow {
  id: string;
  client_id: string | null;
  asset_id: string;
  start_at: string | null;
  end_at: string | null;
  total_amount: number | null;
  commission_amount: number | null;
  deposit_amount: number | null;
  deposit_released: boolean;
  stripe_payment_intent_id: string | null;
  stripe_hold_intent_id: string | null;
  status: BookingStatus;
  access_qr_code: string | null;
  nfc_card_id: string | null;
  checkin_photos: string[] | null;
  checkout_photos: string[] | null;
  checklist_ok: boolean | null;
  damage_amount: number;
  created_at: string;
}
