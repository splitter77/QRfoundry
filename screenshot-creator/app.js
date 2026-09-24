const SIZES = [
  {
    id: "iphone-65-1242",
    label: "iPhone 6.5\" (1242)",
    detail: "1242 × 2688 · required by ASC",
    width: 1242,
    height: 2688,
  },
  {
    id: "iphone-65-1284",
    label: "iPhone 6.5\" (1284)",
    detail: "1284 × 2778 · required by ASC",
    width: 1284,
    height: 2778,
  },
  {
    id: "iphone-65-1242-land",
    label: "iPhone 6.5\" landscape",
    detail: "2688 × 1242",
    width: 2688,
    height: 1242,
  },
  {
    id: "iphone-65-1284-land",
    label: "iPhone 6.5\" landscape",
    detail: "2778 × 1284",
    width: 2778,
    height: 1284,
  },
  {
    id: "iphone-67",
    label: "iPhone 6.7\"",
    detail: "1290 × 2796",
    width: 1290,
    height: 2796,
  },
  {
    id: "iphone-69",
    label: "iPhone 6.9\"",
    detail: "1320 × 2868",
    width: 1320,
    height: 2868,
  },
  {
    id: "ipad-129",
    label: "iPad 12.9\"",
    detail: "2048 × 2732",
    width: 2048,
    height: 2732,
  },
];

const state = {
  items: [],
  activeIndex: -1,
  sizeId: SIZES[0].id,
  zoom: 1,
  offsetX: 0,
  offsetY: 0,
  dragging: false,
  lastX: 0,
  lastY: 0,
};

const els = {
  sizeList: document.getElementById("sizeList"),
  fileInput: document.getElementById("fileInput"),
  dropzone: document.getElementById("dropzone"),
  previewWrap: document.getElementById("previewWrap"),
  preview: document.getElementById("preview"),
  queue: document.getElementById("queue"),
  zoom: document.getElementById("zoom"),
  resetBtn: document.getElementById("resetBtn"),
  exportOneBtn: document.getElementById("exportOneBtn"),
  exportAllBtn: document.getElementById("exportAllBtn"),
  metaName: document.getElementById("metaName"),
  metaSize: document.getElementById("metaSize"),
};

function currentSize() {
  return SIZES.find((s) => s.id === state.sizeId) || SIZES[0];
}

function activeItem() {
  return state.items[state.activeIndex] || null;
}

function renderSizes() {
  els.sizeList.innerHTML = SIZES.map(
    (s) => `
    <button type="button" class="size-btn ${s.id === state.sizeId ? "is-active" : ""}" data-size="${s.id}">
      <strong>${s.label}</strong>
      <span>${s.detail}</span>
    </button>`
  ).join("");
}

function renderQueue() {
  if (!state.items.length) {
    els.queue.innerHTML = `<p class="hint">No images yet.</p>`;
    return;
  }

  els.queue.innerHTML = state.items
    .map(
      (item, i) => `
      <div class="queue-item ${i === state.activeIndex ? "is-active" : ""}" data-index="${i}">
        <img src="${item.url}" alt="" />
        <p title="${item.name}">${item.name}</p>
        <button type="button" data-remove="${i}" aria-label="Remove">×</button>
      </div>`
    )
    .join("");
}

function resetCrop() {
  state.zoom = 1;
  state.offsetX = 0;
  state.offsetY = 0;
  els.zoom.value = "1";
}

function setActive(index) {
  state.activeIndex = index;
  resetCrop();
  updateUI();
  drawPreview();
}

function updateUI() {
  const item = activeItem();
  const size = currentSize();
  const hasItems = state.items.length > 0;

  els.dropzone.classList.toggle("is-hidden", hasItems);
  els.previewWrap.classList.toggle("is-hidden", !hasItems);
  els.exportOneBtn.disabled = !item;
  els.exportAllBtn.disabled = !hasItems;

  if (item) {
    els.metaName.textContent = item.name;
    els.metaSize.textContent = `${size.width} × ${size.height}`;
  } else {
    els.metaName.textContent = "—";
    els.metaSize.textContent = "—";
  }

  renderSizes();
  renderQueue();
}

function coverRect(imgW, imgH, frameW, frameH, zoom, ox, oy) {
  const scale = Math.max(frameW / imgW, frameH / imgH) * zoom;
  const drawW = imgW * scale;
  const drawH = imgH * scale;

  const maxOx = Math.max(0, (drawW - frameW) / 2);
  const maxOy = Math.max(0, (drawH - frameH) / 2);
  const clampedX = Math.min(maxOx, Math.max(-maxOx, ox));
  const clampedY = Math.min(maxOy, Math.max(-maxOy, oy));

  return {
    x: (frameW - drawW) / 2 + clampedX,
    y: (frameH - drawH) / 2 + clampedY,
    w: drawW,
    h: drawH,
    ox: clampedX,
    oy: clampedY,
  };
}

function drawPreview() {
  const item = activeItem();
  if (!item) return;

  const size = currentSize();
  const canvas = els.preview;
  const ctx = canvas.getContext("2d");

  // Display canvas at a readable size, keep aspect of target
  const maxDisplayW = Math.min(420, window.innerWidth * 0.9);
  const maxDisplayH = Math.min(window.innerHeight - 160, 780);
  const displayScale = Math.min(maxDisplayW / size.width, maxDisplayH / size.height);

  canvas.width = Math.round(size.width * displayScale);
  canvas.height = Math.round(size.height * displayScale);

  ctx.fillStyle = "#000";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  const rect = coverRect(
    item.image.width,
    item.image.height,
    canvas.width,
    canvas.height,
    state.zoom,
    state.offsetX,
    state.offsetY
  );

  state.offsetX = rect.ox;
  state.offsetY = rect.oy;

  ctx.drawImage(item.image, rect.x, rect.y, rect.w, rect.h);
}

function exportCanvas(item, size, zoom, ox, oy) {
  const canvas = document.createElement("canvas");
  canvas.width = size.width;
  canvas.height = size.height;
  const ctx = canvas.getContext("2d");
  ctx.fillStyle = "#000";
  ctx.fillRect(0, 0, size.width, size.height);

  // Map preview offsets (in display pixels) to export pixels
  const preview = els.preview;
  const scaleX = size.width / preview.width;
  const scaleY = size.height / preview.height;

  const rect = coverRect(
    item.image.width,
    item.image.height,
    size.width,
    size.height,
    zoom,
    ox * scaleX,
    oy * scaleY
  );

  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = "high";
  ctx.drawImage(item.image, rect.x, rect.y, rect.w, rect.h);
  return canvas;
}

function downloadCanvas(canvas, filename) {
  canvas.toBlob((blob) => {
    if (!blob) return;
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = filename;
    a.click();
    URL.revokeObjectURL(a.href);
  }, "image/png");
}

function slug(name) {
  return name.replace(/\.[^.]+$/, "").replace(/[^\w\-]+/g, "_").slice(0, 40);
}

function exportOne() {
  const item = activeItem();
  if (!item) return;
  const size = currentSize();
  const canvas = exportCanvas(item, size, state.zoom, state.offsetX, state.offsetY);
  downloadCanvas(canvas, `${slug(item.name)}_${size.width}x${size.height}.png`);
}

async function exportAll() {
  const size = currentSize();
  for (const item of state.items) {
    // Use each item's last crop if we stored it; otherwise current global crop
    const zoom = item.zoom ?? state.zoom;
    const ox = item.offsetX ?? state.offsetX;
    const oy = item.offsetY ?? state.offsetY;
    const canvas = exportCanvas(item, size, zoom, ox, oy);
    downloadCanvas(canvas, `${slug(item.name)}_${size.width}x${size.height}.png`);
    await new Promise((r) => setTimeout(r, 150));
  }
}

function rememberCrop() {
  const item = activeItem();
  if (!item) return;
  item.zoom = state.zoom;
  item.offsetX = state.offsetX;
  item.offsetY = state.offsetY;
}

function loadFiles(fileList) {
  const files = [...fileList].filter((f) => f.type.startsWith("image/"));
  if (!files.length) return;

  files.forEach((file) => {
    const url = URL.createObjectURL(file);
    const image = new Image();
    image.onload = () => {
      state.items.push({ name: file.name, url, image });
      if (state.activeIndex < 0) setActive(0);
      else updateUI();
    };
    image.src = url;
  });
}

function bindEvents() {
  els.fileInput.addEventListener("change", (e) => {
    loadFiles(e.target.files);
    e.target.value = "";
  });

  ["dragenter", "dragover"].forEach((evt) => {
    els.dropzone.addEventListener(evt, (e) => {
      e.preventDefault();
      els.dropzone.classList.add("is-drag");
    });
    document.body.addEventListener(evt, (e) => e.preventDefault());
  });

  ["dragleave", "drop"].forEach((evt) => {
    els.dropzone.addEventListener(evt, (e) => {
      e.preventDefault();
      els.dropzone.classList.remove("is-drag");
    });
  });

  els.dropzone.addEventListener("drop", (e) => {
    loadFiles(e.dataTransfer.files);
  });

  document.body.addEventListener("drop", (e) => {
    e.preventDefault();
    if (e.dataTransfer?.files?.length) loadFiles(e.dataTransfer.files);
  });

  els.sizeList.addEventListener("click", (e) => {
    const btn = e.target.closest("[data-size]");
    if (!btn) return;
    rememberCrop();
    state.sizeId = btn.dataset.size;
    resetCrop();
    updateUI();
    drawPreview();
  });

  els.queue.addEventListener("click", (e) => {
    const remove = e.target.closest("[data-remove]");
    if (remove) {
      const i = Number(remove.dataset.remove);
      URL.revokeObjectURL(state.items[i].url);
      state.items.splice(i, 1);
      if (!state.items.length) {
        state.activeIndex = -1;
        updateUI();
        return;
      }
      setActive(Math.min(i, state.items.length - 1));
      return;
    }

    const row = e.target.closest("[data-index]");
    if (!row) return;
    rememberCrop();
    setActive(Number(row.dataset.index));
  });

  els.zoom.addEventListener("input", () => {
    state.zoom = Number(els.zoom.value);
    drawPreview();
    rememberCrop();
  });

  els.resetBtn.addEventListener("click", () => {
    resetCrop();
    drawPreview();
    rememberCrop();
  });

  els.exportOneBtn.addEventListener("click", exportOne);
  els.exportAllBtn.addEventListener("click", exportAll);

  const canvas = els.preview;
  canvas.addEventListener("pointerdown", (e) => {
    state.dragging = true;
    state.lastX = e.clientX;
    state.lastY = e.clientY;
    canvas.setPointerCapture(e.pointerId);
  });
  canvas.addEventListener("pointermove", (e) => {
    if (!state.dragging) return;
    state.offsetX += e.clientX - state.lastX;
    state.offsetY += e.clientY - state.lastY;
    state.lastX = e.clientX;
    state.lastY = e.clientY;
    drawPreview();
  });
  canvas.addEventListener("pointerup", () => {
    state.dragging = false;
    rememberCrop();
  });
  canvas.addEventListener("pointercancel", () => {
    state.dragging = false;
  });

  window.addEventListener("resize", () => {
    if (activeItem()) drawPreview();
  });
}

bindEvents();
updateUI();
