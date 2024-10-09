/* !include https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/js/tabler.min.js */
/* !include https://cdn.jsdelivr.net/npm/list.js-fixed@2.3.4/dist/list.min.js */

const nonce = document.currentScript.nonce;

function sqlpage_embed() {
  for (const c of document.querySelectorAll("[data-embed]:not([aria-busy=true])")) {
    c.ariaBusy = true;
    let url;
    try {
      url = new URL(c.dataset.embed, window.location.href)
    } catch {
      console.error(`'${c.dataset.embed}' is not a valid url`)
      continue;
    }
    url.searchParams.set("_sqlpage_embed", "");

    fetch(url)
      .then(res => res.text())
      .then(html => {
        c.innerHTML = html;
        c.ariaBusy = false;
        delete c.dataset.embed;
        c.dispatchEvent(new CustomEvent("fragment-loaded", {
          bubbles: true
      }));
    })
    .catch(err => console.error("Fetch error: ", err));
    }
}

function sqlpage_table(){
    // Tables
    for (const r of document.querySelectorAll("[data-pre-init=table]")) {
        new List(r, {
            valueNames: [...r.getElementsByTagName("th")].map(t => t.textContent),
            searchDelay: 100,
            // Hurts performance, but prevents https://github.com/lovasoa/SQLpage/issues/542
            // indexAsync: true
        });
        r.removeAttribute("data-pre-init");
    }
}

function sqlpage_select_dropdown(){
  const selects = document.querySelectorAll("[data-pre-init=select-dropdown]");
  if (!selects.length) return;
  const src = "https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.popular.min.js";
  if (!window.TomSelect) {
    const script = document.createElement("script");
    script.src= src;
    script.integrity = "sha384-aAqv9vleUwO75zAk1sGKd5VvRqXamBXwdxhtihEUPSeq1HtxwmZqQG/HxQnq7zaE";
    script.crossOrigin = "anonymous";
    script.nonce = nonce;
    script.onload = sqlpage_select_dropdown;
    document.head.appendChild(script);
    return;
  }
  for (const s of selects) {
      new TomSelect(s, {
        create: s.dataset.create_new
      });
  }
}

let is_leaflet_injected = false;
let is_leaflet_loaded = false;

function sqlpage_map() {
    const first_map = document.querySelector("[data-pre-init=map]");
    if (first_map && !is_leaflet_injected) {
      // Add the leaflet js and css to the page
      const leaflet_css = document.createElement("link");
      leaflet_css.rel = "stylesheet";
      leaflet_css.href = "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css";
      leaflet_css.integrity = "sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=";
      leaflet_css.crossOrigin = "anonymous";
      document.head.appendChild(leaflet_css);
      const leaflet_js = document.createElement("script");
      leaflet_js.src = "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js";
      leaflet_js.integrity = "sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=";
      leaflet_js.crossOrigin = "anonymous";
      leaflet_js.nonce = nonce;
      leaflet_js.onload = onLeafletLoad;
      document.head.appendChild(leaflet_js);
      is_leaflet_injected = true;
    }
    if (first_map && is_leaflet_loaded) {
      onLeafletLoad();
    }
    function parseCoords(coords) {
      return coords && coords.split(",").map(c => parseFloat(c));
    }
    function onLeafletLoad() {
      is_leaflet_loaded = true;
      const maps = document.querySelectorAll("[data-pre-init=map]");
      for (const m of maps) {
        const tile_source = m.dataset.tile_source;
        const maxZoom = +m.dataset.max_zoom;
        const attribution = m.dataset.attribution;
        const map = L.map(m, { attributionControl: !!attribution });
        const zoom = m.dataset.zoom;
        let center = parseCoords(m.dataset.center);
        if (tile_source) L.tileLayer(tile_source, { attribution, maxZoom }).addTo(map);
        map._sqlpage_markers = [];
        for (const marker_elem of m.getElementsByClassName("marker")) {
          setTimeout(addMarker, 0, marker_elem, map);
        }
        setTimeout(() => {
          if (center == null && map._sqlpage_markers.length) {
            map.fitBounds(map._sqlpage_markers.map(m => 
              m.getLatLng ? m.getLatLng() : m.getBounds()
            ));
            if (zoom != null) map.setZoom(+zoom);
          } else map.setView(center, +zoom);
        }, 100);
        m.removeAttribute("data-pre-init");
        m.getElementsByClassName("spinner-border")[0]?.remove();
      }
    }

    function addMarker(marker_elem, map) {
      const { dataset } = marker_elem;
      const options = {
        color: marker_elem.dataset.color,
        title: marker_elem.getElementsByTagName("h3")[0].textContent.trim(),
      };
      const marker = 
        dataset.coords ? createMarker(marker_elem, options)
                       : createGeoJSONMarker(marker_elem, options);
      marker.addTo(map);
      map._sqlpage_markers.push(marker);
      if (options.title) marker.bindPopup(marker_elem);
      else if (marker_elem.dataset.link) marker.on('click', () => window.location = marker_elem.dataset.link);
    }
    function createMarker(marker_elem, options) {
      const coords = parseCoords(marker_elem.dataset.coords);
      const icon_obj = marker_elem.getElementsByClassName("mapicon")[0];
      if (icon_obj) {
        const size = 1.5 * +(options.size || icon_obj.firstChild?.getAttribute('width') || 24);
        options.icon = L.divIcon({
          html: icon_obj,
          className: `border-0 bg-${options.color || 'primary'} bg-gradient text-white rounded-circle shadow d-flex justify-content-center align-items-center`,
          iconSize: [size, size],
          iconAnchor: [size/2, size/2],
        });
      }
      return L.marker(coords, options);
    }
    function createGeoJSONMarker(marker_elem, options) {
      let geojson = JSON.parse(marker_elem.dataset.geojson);
      if (options.color) {
        options.color = get_tabler_color(options.color) || options.color;
      }
      function style({ properties }) {
        if (typeof properties !== "object") return options;
        return {...options, ...properties};
      }
      function pointToLayer(feature, latlng) {
        marker_elem.dataset.coords = latlng.lat + "," + latlng.lng;
        return createMarker(marker_elem, { ...options, ...feature.properties });
      }
      return L.geoJSON(geojson, { style, pointToLayer });
    }
}

function sqlpage_form() {
    const file_inputs = document.querySelectorAll("input[type=file][data-max-size]");
    for (const input of file_inputs) {
      const max_size = +input.dataset.maxSize;
      input.addEventListener("change", function() {
        input.classList.remove("is-invalid");
        input.setCustomValidity("");
        for (const {size} of this.files) {
          if (size > max_size){
            input.classList.add("is-invalid");
            return input.setCustomValidity(`File size must be less than ${max_size/1000} kB.`);
          }
        }
      });
    }
}

function create_tabler_color() {
    const style = getComputedStyle(document.documentElement);
  return function get_tabler_color(name) {
    return style.getPropertyValue('--tblr-' + name);
}
}

const get_tabler_color = create_tabler_color();

function load_scripts() {
  let addjs = document.querySelectorAll("[data-sqlpage-js]");
  for (const js of new Set([...addjs].map(({dataset}) => dataset.sqlpageJs))) {
    const script = document.createElement("script");
    script.src = js;
    document.head.appendChild(script);
  }
}

function add_init_fn(f) {
  document.addEventListener('DOMContentLoaded', f);
  document.addEventListener('fragment-loaded', f);
  if (document.readyState !== "loading") setTimeout(f, 0);
}


add_init_fn(sqlpage_table);
add_init_fn(sqlpage_map);
add_init_fn(sqlpage_embed);
add_init_fn(sqlpage_form);
add_init_fn(load_scripts);
