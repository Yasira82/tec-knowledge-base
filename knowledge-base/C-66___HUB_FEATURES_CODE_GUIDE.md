# C-66 — HUB FEATURES CODE GUIDE

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


KYC + Subscription + Notifications — كود جاهز للتنفيذ

⚠️ اقرأ C-58 أولاً (Hub Completion Plan)
الـ pages موجودة في /dashboard — المشكلة في الـ integration

---

## الأولوية

```
1. Fix NEW-A في كل routes (11 ملف)
2. Subscription upgrade Pi payment
3. Verify KYC R2 upload
4. Realtime notifications
```

---

## 1. FIX NEW-A — الخطوة الأولى في كل route

```typescript
// ✅ طبّق على الـ 11 route دي في Hub:
const GW = process.env.API_GATEWAY_URL
        ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL!;

// الملفات:
// src/app/api/kyc/start/route.ts
// src/app/api/kyc/upload/route.ts
// src/app/api/kyc/submit/route.ts
// src/app/api/kyc/status/route.ts
// src/app/api/bff/kyc/status/route.ts
// src/app/api/subscriptions/route.ts
// src/app/api/notifications/route.ts
// src/app/api/notifications/[id]/read/route.ts
// src/app/api/notifications/unread-count/route.ts
// src/app/api/notifications/read-all/route.ts
// src/app/api/bff/notifications/list/route.ts
```

---

## 2. SUBSCRIPTION UPGRADE — كود كامل

### 2.1 BFF Route

```typescript
// src/app/api/bff/subscription/upgrade/route.ts

import { NextRequest, NextResponse } from 'next/server';

const GW = process.env.API_GATEWAY_URL
        ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL!;

const getToken = (r: NextRequest) =>
  r.cookies.get('tec_access_token')?.value ?? null;
const getCsrf  = (r: NextRequest) =>
  r.cookies.get('tec_csrf')?.value ?? '';

export async function POST(req: NextRequest) {
  const token = getToken(req);
  if (!token) return NextResponse.json(
    { success: false, error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } },
    { status: 401 }
  );

  const csrfCookie = getCsrf(req);
  const csrfHeader = req.headers.get('x-csrf-token') ?? '';
  if (!csrfCookie || csrfCookie !== csrfHeader) return NextResponse.json(
    { success: false, error: { code: 'CSRF_INVALID', message: 'CSRF validation failed' } },
    { status: 403 }
  );

  const body = await req.json().catch(() => ({})) as {
    plan:       'PRO' | 'ENTERPRISE';
    payment_id: string;
  };

  if (!['PRO', 'ENTERPRISE'].includes(body.plan)) return NextResponse.json(
    { success: false, error: { code: 'VALIDATION_ERROR', message: 'Invalid plan' } },
    { status: 400 }
  );

  const res = await fetch(`${GW}/api/v1/auth/subscription/upgrade`, {
    method:  'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization:  `Bearer ${token}`,
    },
    body: JSON.stringify({ plan: body.plan, payment_id: body.payment_id }),
  }).catch(() => null);

  if (!res) return NextResponse.json(
    { success: false, error: { code: 'SERVICE_UNAVAILABLE', message: 'Service unavailable' } },
    { status: 503 }
  );

  const data = await res.json().catch(() => ({}));
  return NextResponse.json(data, { status: res.status });
}
```

### 2.2 Frontend — Subscription Upgrade

```typescript
// src/app/dashboard/subscription/page.tsx

'use client';
import { useState, useCallback }    from 'react';
import { useRouter }                from 'next/navigation';
import { createPaymentRecord, createU2APayment } from '@yasser172/tec-ui/payment';

const PRICES: Record<string, number> = { PRO: 10, ENTERPRISE: 50 };

const getCsrfToken = () =>
  document.cookie.split('; ')
    .find(r => r.startsWith('tec_csrf='))
    ?.split('=')?.[1] ?? '';

export default function SubscriptionPage() {
  const router  = useRouter();
  const [loading, setLoading] = useState(false);
  const [status,  setStatus]  = useState<string | null>(null);

  const handleUpgrade = useCallback(async (plan: 'PRO' | 'ENTERPRISE') => {
    setLoading(true);
    setStatus(null);

    try {
      const price = PRICES[plan];
      const memo  = `TEC ${plan} Subscription`;

      const internalId = await createPaymentRecord(price, `subscription_${plan.toLowerCase()}`, memo, 'hub');
      if (!internalId) { setStatus('error'); return; }

      const result = await createU2APayment(price, memo, { plan, type: 'subscription' }, internalId);

      if (result.success) {
        await fetch('/api/bff/subscription/upgrade', {
          method:      'POST',
          credentials: 'include',
          headers: {
            'Content-Type': 'application/json',
            'x-csrf-token': getCsrfToken(),
          },
          body: JSON.stringify({ plan, payment_id: internalId }),
        });
        setStatus('success');
        router.refresh();
      } else {
        setStatus(result.status === 'cancelled' ? 'cancelled' : 'error');
      }
    } finally {
      setLoading(false);
    }
  }, [router]);

  return (
    <div>
      <button onClick={() => handleUpgrade('PRO')}        disabled={loading}>
        Upgrade to PRO — 10π/month
      </button>
      <button onClick={() => handleUpgrade('ENTERPRISE')} disabled={loading}>
        Upgrade to ENTERPRISE — 50π/month
      </button>
      {status === 'success'   && <p>✅ Upgraded successfully!</p>}
      {status === 'cancelled' && <p>Payment cancelled.</p>}
      {status === 'error'     && <p>Something went wrong. Try again.</p>}
    </div>
  );
}
```

---

## 3. KYC — Upload Flow

```typescript
// src/app/api/kyc/upload/route.ts

import { NextRequest, NextResponse } from 'next/server';

const GW            = process.env.API_GATEWAY_URL
                   ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL!;
const MAX_SIZE      = 10 * 1024 * 1024; // 10MB
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'application/pdf'];

export async function POST(req: NextRequest) {
  const token = req.cookies.get('tec_access_token')?.value;
  if (!token) return NextResponse.json(
    { success: false, error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } },
    { status: 401 }
  );

  const formData = await req.formData().catch(() => null);
  if (!formData) return NextResponse.json(
    { success: false, error: { code: 'VALIDATION_ERROR', message: 'Invalid form data' } },
    { status: 400 }
  );

  const file = formData.get('file') as File | null;
  if (!file) return NextResponse.json(
    { success: false, error: { code: 'MISSING_FIELD', message: 'File required', field: 'file' } },
    { status: 400 }
  );

  if (file.size > MAX_SIZE) return NextResponse.json(
    { success: false, error: { code: 'VALIDATION_ERROR', message: 'File too large (max 10MB)' } },
    { status: 400 }
  );

  if (!ALLOWED_TYPES.includes(file.type)) return NextResponse.json(
    { success: false, error: { code: 'VALIDATION_ERROR', message: 'Use JPEG, PNG, or PDF only' } },
    { status: 400 }
  );

  const upstream = new FormData();
  upstream.append('file', file);
  upstream.append('type', formData.get('type') as string ?? 'kyc_document');

  const res = await fetch(`${GW}/api/v1/kyc/upload`, {
    method:  'POST',
    headers: { Authorization: `Bearer ${token}` },
    body:    upstream,
  }).catch(() => null);

  if (!res) return NextResponse.json(
    { success: false, error: { code: 'SERVICE_UNAVAILABLE', message: 'Service unavailable' } },
    { status: 503 }
  );

  const data = await res.json().catch(() => ({}));
  return NextResponse.json(data, { status: res.status });
}
```

---

## 4. NOTIFICATIONS — Realtime Hook

```typescript
// src/lib-client/hooks/useNotifications.ts

'use client';
import { useState, useEffect, useCallback, useRef } from 'react';

interface Notification {
  id:        string;
  type:      string;
  title:     string;
  message:   string;
  read:      boolean;
  createdAt: string;
}

const getCsrfToken = () =>
  document.cookie.split('; ')
    .find(r => r.startsWith('tec_csrf='))
    ?.split('=')?.[1] ?? '';

const getAccessToken = () =>
  document.cookie.split('; ')
    .find(r => r.startsWith('tec_access_token='))
    ?.split('=')?.[1] ?? null;

export const useNotifications = () => {
  const [notifs,      setNotifs]      = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [isLoading,   setIsLoading]   = useState(true);
  const wsRef = useRef<WebSocket | null>(null);

  const fetchNotifications = useCallback(async () => {
    const res  = await fetch('/api/bff/notifications/list', { credentials: 'include' });
    const data = await res.json();
    if (data.success) {
      setNotifs(data.data ?? []);
      setUnreadCount(data.data?.filter((n: Notification) => !n.read).length ?? 0);
    }
    setIsLoading(false);
  }, []);

  const connectRealtime = useCallback(() => {
    const token = getAccessToken();
    if (!token) return;

    const REALTIME_URL = 'wss://realtime-service-production.up.railway.app';
    const ws = new WebSocket(REALTIME_URL);
    wsRef.current = ws;

    ws.onopen = () => {
      ws.send(JSON.stringify({ type: 'auth', token }));
    };

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.type === 'notification.new') {
        setNotifs(prev => [data.payload, ...prev]);
        setUnreadCount(c => c + 1);
      }
    };

    ws.onclose = () => { setTimeout(connectRealtime, 3000); };
  }, []);

  useEffect(() => {
    fetchNotifications();
    connectRealtime();
    return () => wsRef.current?.close();
  }, [fetchNotifications, connectRealtime]);

  const markRead = async (id: string) => {
    await fetch(`/api/notifications/${id}/read`, {
      method:      'POST',
      credentials: 'include',
      headers:     { 'x-csrf-token': getCsrfToken() },
    });
    setNotifs(prev => prev.map(n => n.id === id ? { ...n, read: true } : n));
    setUnreadCount(c => Math.max(0, c - 1));
  };

  const markAllRead = async () => {
    await fetch('/api/notifications/read-all', {
      method:      'POST',
      credentials: 'include',
      headers:     { 'x-csrf-token': getCsrfToken() },
    });
    setNotifs(prev => prev.map(n => ({ ...n, read: true })));
    setUnreadCount(0);
  };

  return { notifs, unreadCount, isLoading, markRead, markAllRead, refetch: fetchNotifications };
};
```

---

## 5. NOTIFICATIONS BFF

```typescript
// src/app/api/bff/notifications/list/route.ts

import { NextRequest, NextResponse } from 'next/server';

const GW = process.env.API_GATEWAY_URL
        ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL!;

export async function GET(req: NextRequest) {
  const token = req.cookies.get('tec_access_token')?.value;
  if (!token) return NextResponse.json(
    { success: false, error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } },
    { status: 401 }
  );

  const res = await fetch(`${GW}/api/v1/notification`, {
    headers: { Authorization: `Bearer ${token}` },
    cache:   'no-store',
  }).catch(() => null);

  if (!res) return NextResponse.json(
    { success: false, error: { code: 'SERVICE_UNAVAILABLE', message: 'Service unavailable' } },
    { status: 503 }
  );

  const data = await res.json().catch(() => ({}));
  return NextResponse.json(data, { status: res.status });
}
```

---

## 6. INTEGRATION TEST CHECKLIST

```
□ KYC:
  □ /dashboard/kyc → يعرض status صح
  □ Upload JPEG → يروح R2 → يرجع URL
  □ Submit → status يتغير لـ PENDING

□ Subscription:
  □ /dashboard/subscription → يعرض الـ plan الحالي
  □ Upgrade PRO → Pi.createPayment() → 10π → success
  □ بعد النجاح → router.refresh() → plan يتحدث

□ Notifications:
  □ /dashboard/notifications → يعرض الـ list
  □ Mark read → unread count يقل
  □ Realtime: payment → notification تيجي تلقائي

□ NEW-A Fixed:
  □ DevTools → Network → مفيش Railway URL في responses
```

---

## Related Contents

- C-12 — Dual-Mode Payment
- C-51 — Cookie Architecture
- C-58 — Hub Completion Plan
- C-59 — Unified Error Format
- C-60 — Code Templates
- C-63 — Pi Network Rules
- C-64 — ADR-001, ADR-006
