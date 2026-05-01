'use client';

import { useEffect, useRef, useState } from 'react';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import { RPBottomSheet, RPStatusBadge } from '@/components/ui';
import { createSupabaseBrowser } from '@/lib/supabase/client';
import type { AssetStatus } from '@/lib/supabase/types';

interface AssetMarker {
  id: string;
  name: string | null;
  category: string | null;
  lat: number | null;
  lng: number | null;
  status: AssetStatus;
}

interface ProviderMarker {
  id: string;
  vehicle_name: string | null;
  service_type: string | null;
  current_lat: number | null;
  current_lng: number | null;
  is_available: boolean;
}

interface Props {
  assets: AssetMarker[];
  providers: ProviderMarker[];
}

function categoryEmoji(cat: string | null): string {
  switch (cat) {
    case 'vehicle':
      return '🚗';
    case 'property':
      return '🏠';
    case 'boat':
      return '⛵';
    case 'equipment':
      return '⚙️';
    case 'tool':
      return '🔨';
    case 'event':
      return '🎉';
    default:
      return '📍';
  }
}

function serviceEmoji(svc: string | null): string {
  switch (svc) {
    case 'taxi':
      return '🚖';
    case 'minibus':
      return '🚐';
    case 'boat':
      return '🛥️';
    case 'truck':
      return '🚚';
    default:
      return '📍';
  }
}

export function LiveMap({ assets, providers }: Props) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<mapboxgl.Map | null>(null);
  const markersRef = useRef<Map<string, mapboxgl.Marker>>(new Map());
  const [selected, setSelected] = useState<AssetMarker | ProviderMarker | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const token = process.env.NEXT_PUBLIC_MAPBOX_TOKEN;
    if (!token) {
      setError('Mapbox non configuré');
      return;
    }
    if (!containerRef.current) return;
    mapboxgl.accessToken = token;

    // Centre par défaut : Paris.
    const center: [number, number] =
      assets[0]?.lng && assets[0]?.lat
        ? [assets[0].lng, assets[0].lat]
        : providers[0]?.current_lng && providers[0]?.current_lat
        ? [providers[0].current_lng, providers[0].current_lat]
        : [2.3522, 48.8566];

    const map = new mapboxgl.Map({
      container: containerRef.current,
      style: 'mapbox://styles/mapbox/dark-v11',
      center,
      zoom: 11,
      attributionControl: false,
    });
    map.addControl(new mapboxgl.NavigationControl({ showCompass: false }), 'top-right');
    mapRef.current = map;

    return () => {
      map.remove();
      mapRef.current = null;
      markersRef.current.clear();
    };
  }, [assets, providers]);

  // Ajoute les markers d'actifs.
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    for (const a of assets) {
      if (a.lng === null || a.lat === null) continue;
      const el = document.createElement('button');
      el.type = 'button';
      el.setAttribute('aria-label', a.name ?? '');
      el.className =
        'flex h-9 w-9 items-center justify-center rounded-full border-2 border-rp-gold bg-rp-dark text-base shadow-rp-gold transition hover:scale-110';
      el.textContent = categoryEmoji(a.category);
      el.onclick = () => setSelected(a);
      const marker = new mapboxgl.Marker({ element: el })
        .setLngLat([a.lng, a.lat])
        .addTo(map);
      markersRef.current.set(`a:${a.id}`, marker);
    }
    for (const p of providers) {
      if (p.current_lng === null || p.current_lat === null) continue;
      const el = document.createElement('button');
      el.type = 'button';
      el.className =
        'flex h-9 w-9 items-center justify-center rounded-full border-2 border-rp-success bg-rp-dark text-base shadow-rp transition hover:scale-110';
      el.textContent = serviceEmoji(p.service_type);
      el.onclick = () => setSelected(p);
      const marker = new mapboxgl.Marker({ element: el })
        .setLngLat([p.current_lng, p.current_lat])
        .addTo(map);
      markersRef.current.set(`p:${p.id}`, marker);
    }
    return () => {
      for (const m of markersRef.current.values()) m.remove();
      markersRef.current.clear();
    };
  }, [assets, providers]);

  // Realtime : MAJ des positions des prestataires + statuts des biens.
  useEffect(() => {
    const supabase = createSupabaseBrowser();
    const channel = supabase
      .channel('live-map')
      .on(
        'postgres_changes',
        { event: 'UPDATE', schema: 'public', table: 'providers' },
        (payload) => {
          const p = payload.new as {
            id: string;
            current_lat: number | null;
            current_lng: number | null;
          };
          const m = markersRef.current.get(`p:${p.id}`);
          if (m && p.current_lat !== null && p.current_lng !== null) {
            m.setLngLat([p.current_lng, p.current_lat]);
          }
        }
      )
      .on(
        'postgres_changes',
        { event: 'UPDATE', schema: 'public', table: 'assets' },
        (payload) => {
          const a = payload.new as { id: string; status: AssetStatus };
          const el = markersRef.current.get(`a:${a.id}`)?.getElement();
          if (el) {
            el.classList.toggle('border-rp-gold', a.status === 'available');
            el.classList.toggle('border-rp-danger', a.status === 'occupied');
            el.classList.toggle('border-rp-warning', a.status === 'cleaning');
          }
        }
      )
      .subscribe();
    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  return (
    <div className="relative">
      <div ref={containerRef} className="h-[calc(100dvh-72px)] w-full" />

      {error ? (
        <div className="absolute inset-x-5 top-5 rounded-rp border border-rp-warning/40 bg-rp-warning/10 p-3 text-sm text-rp-warning">
          {error}
        </div>
      ) : null}

      <Legend />

      <RPBottomSheet
        open={Boolean(selected)}
        onClose={() => setSelected(null)}
        title={
          selected && 'name' in selected
            ? selected.name ?? 'Bien'
            : selected && 'vehicle_name' in selected
            ? selected.vehicle_name ?? 'Prestataire'
            : ''
        }
      >
        {selected && 'category' in selected ? (
          <div className="space-y-3">
            <RPStatusBadge status={selected.status} />
            <p className="text-sm text-rp-gray">
              Catégorie : {selected.category}
            </p>
            <a
              href={`/location/${selected.id}`}
              className="block rounded-rp-btn rp-gradient-gold py-3 text-center text-sm font-medium text-rp-black"
            >
              Voir le bien
            </a>
          </div>
        ) : null}

        {selected && 'service_type' in selected ? (
          <div className="space-y-3">
            <p className="text-sm text-rp-gray">
              Service : {selected.service_type}
            </p>
            <a
              href={`/transport/${selected.id}`}
              className="block rounded-rp-btn rp-gradient-gold py-3 text-center text-sm font-medium text-rp-black"
            >
              Réserver une course
            </a>
          </div>
        ) : null}
      </RPBottomSheet>
    </div>
  );
}

function Legend() {
  return (
    <div className="absolute left-3 top-3 flex flex-col gap-1 rounded-rp border border-rp-border bg-rp-dark/85 px-2.5 py-2 text-[10px] text-rp-gray backdrop-blur">
      <span className="inline-flex items-center gap-1.5">
        <span className="h-2 w-2 rounded-full border border-rp-gold bg-rp-dark" />
        Bien
      </span>
      <span className="inline-flex items-center gap-1.5">
        <span className="h-2 w-2 rounded-full border border-rp-success bg-rp-dark" />
        Prestataire en ligne
      </span>
    </div>
  );
}

