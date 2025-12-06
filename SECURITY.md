# Panduan Keamanan Supabase untuk Android

## Status Keamanan Saat Ini ✅

### Yang Sudah Diimplementasikan:
1. ✅ **Environment Variables** - Credentials tidak hardcoded
2. ✅ **Secure Storage** - Session tokens disimpan encrypted
3. ✅ **flutter_dotenv** - Manajemen konfigurasi runtime
4. ✅ **flutter_secure_storage** - Enkripsi untuk sensitive data

---

## Keamanan di Android - Penjelasan

### 1. **Anon Key Visibility**
**Q: Apakah aman jika Anon Key terlihat di APK?**

**A: YA, ini normal dan aman jika dikonfigurasi dengan benar.**

**Alasan:**
- Anon Key adalah **public key** yang dimaksudkan untuk klien
- Dibuat khusus untuk akses terbatas (read-only atau dengan RLS)
- Berbeda dengan Private Key yang HARUS disembunyi

**Keamanan sebenarnya terletak pada:**
- ✅ Row Level Security (RLS) di database
- ✅ Authorization policies
- ✅ Rate limiting di backend
- ✅ Input validation

---

## Checklist Keamanan Supabase

### ✅ Di Code Level:
- [x] Environment variables (bukan hardcoded)
- [x] Session management dengan secure storage
- [x] Input sanitization available
- [x] Error handling yang proper

### 📋 Di Supabase Dashboard (PENTING):

Masuk ke https://app.supabase.com dan lakukan:

#### 1. **Enable Row Level Security (RLS)**
```sql
-- Untuk table `products` (read-only untuk anonymous)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Products readable by everyone"
ON products FOR SELECT
USING (true);

-- Untuk table `cart_items` (hanya user sendiri yang bisa akses)
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own cart"
ON cart_items FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own cart"
ON cart_items FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own cart"
ON cart_items FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own cart"
ON cart_items FOR DELETE
USING (auth.uid() = user_id);
```

#### 2. **Setup Rate Limiting** (di Edge Functions atau middleware)
```javascript
// Contoh di Supabase Edge Functions
const rateLimit = new Map();

export async function handleRequest(req) {
  const userId = req.headers.get('x-user-id');
  
  if (!rateLimit.has(userId)) {
    rateLimit.set(userId, { count: 0, timestamp: Date.now() });
  }
  
  const userLimit = rateLimit.get(userId);
  const now = Date.now();
  
  // Reset setiap menit
  if (now - userLimit.timestamp > 60000) {
    userLimit.count = 0;
    userLimit.timestamp = now;
  }
  
  // Max 100 requests per menit
  if (userLimit.count >= 100) {
    return new Response('Too many requests', { status: 429 });
  }
  
  userLimit.count++;
  // ... lanjutkan request
}
```

#### 3. **Configure CORS** (di Authentication Settings)
- Tambahkan URL Android app Anda
- Untuk development: `*` (tidak aman untuk production)
- Untuk production: specific domain saja

#### 4. **Setup Email Confirmations**
- Enable email verification untuk signup
- Cegah bot registrations

#### 5. **Monitor Logs**
- Dashboard → Logs → Auth logs
- Pantau failed login attempts
- Setup alerts untuk suspicious activity

---

## Best Practices untuk Android App

### 1. **Jangan Simpan Sensitive Data**
```dart
// ❌ JANGAN LAKUKAN
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setString('anon_key', 'eyJ...');

// ✅ LAKUKAN INI
// flutter_secure_storage otomatis terenkripsi
_secureStorage.write(key: 'session_token', value: token);
```

### 2. **Validasi Input**
```dart
// ✅ Gunakan sanitizeInput sebelum query
String searchTerm = SupabaseService.sanitizeInput(userInput);
```

### 3. **Handle Auth Errors**
```dart
try {
  await client.auth.signInWithPassword(
    email: email,
    password: password,
  );
} catch (e) {
  // ✅ Log event keamanan
  await SupabaseService.logSecurityEvent(
    eventType: 'failed_login',
    description: 'Failed login attempt',
    metadata: {'email': email},
  );
}
```

### 4. **Expire Sessions**
```dart
// Implementasikan session timeout
void _startSessionTimer() {
  Timer(Duration(hours: 24), () async {
    await Supabase.instance.client.auth.signOut();
    // Redirect ke login page
  });
}
```

---

## Kontrol Akses - Role Based Access Control (RBAC)

### Setup di Supabase:

```sql
-- Table untuk user roles
CREATE TABLE user_roles (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  role TEXT CHECK (role IN ('customer', 'admin', 'moderator')),
  created_at TIMESTAMP DEFAULT now()
);

-- Policy untuk admin-only operations
CREATE POLICY "Only admins can update products"
ON products FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);
```

### Di Flutter Code:
```dart
Future<bool> isAdmin() async {
  final user = SupabaseService.currentUser;
  if (user == null) return false;
  
  final response = await SupabaseService.client
    .from('user_roles')
    .select()
    .eq('user_id', user.id)
    .eq('role', 'admin')
    .single();
  
  return response != null;
}
```

---

## Security Checklist Sebelum Production

- [ ] Row Level Security (RLS) enabled untuk semua tables
- [ ] Authorization policies dikonfigurasi
- [ ] Rate limiting diaktifkan
- [ ] Email verification diaktifkan
- [ ] CORS dikonfigurasi dengan benar
- [ ] Session timeout implemented
- [ ] Input validation di semua user inputs
- [ ] Error messages tidak expose sensitive info
- [ ] Security logs setup untuk monitoring
- [ ] API keys di Supabase di-rotate secara berkala
- [ ] Sensitive data tidak disimpan di SharedPreferences
- [ ] HTTPS digunakan untuk semua requests

---

## Kesimpulan

**Untuk Android: AMAN dengan konfigurasi saat ini jika:**

1. ✅ Supabase RLS policies dikonfigurasi dengan benar
2. ✅ Anon key hanya memiliki limited permissions
3. ✅ Backend validation dilakukan untuk semua requests
4. ✅ Session tokens disimpan securely
5. ✅ Rate limiting diimplementasikan

**Status: Ready untuk production dengan checklist di atas dipenuhi.**
