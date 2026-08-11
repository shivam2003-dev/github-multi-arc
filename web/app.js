async function loadRuntime() {
  const target = document.querySelector("#runtime");

  try {
    const response = await fetch("/api/info");
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const info = await response.json();

    target.innerHTML = Object.entries(info)
      .map(([name, value]) => `<div><dt>${name}</dt><dd>${value}</dd></div>`)
      .join("");
  } catch (error) {
    target.innerHTML = `<div><dt>Error</dt><dd>${error.message}</dd></div>`;
  }
}

loadRuntime();
