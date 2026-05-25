import { Editor } from "@tiptap/core"
import StarterKit from "@tiptap/starter-kit"
import { Markdown } from "tiptap-markdown"
import Placeholder from "@tiptap/extension-placeholder"

// ─── Tiptap rich-text editor ──────────────────────────────────────────────────

function svgIcon(paths, sw = "1.6") {
  return (
    `<svg width="16" height="16" viewBox="0 0 16 16" fill="none" ` +
    `stroke="currentColor" stroke-width="${sw}" stroke-linecap="round" ` +
    `stroke-linejoin="round">${paths}</svg>`
  )
}

const TOOLBAR_BTNS = [
  {
    action: "bold",
    title: "Bold",
    svg: svgIcon(
      `<path d="M4 3v10"/>` +
      `<path d="M4 3h4a2.5 2.5 0 010 5H4"/>` +
      `<path d="M4 8h4.5a2.5 2.5 0 010 5H4"/>`,
    ),
  },
  {
    action: "italic",
    title: "Italic",
    svg: svgIcon(
      `<path d="M10 3.5H6"/>` +
      `<path d="M10 12.5H6"/>` +
      `<path d="M9 3.5l-2 9"/>`,
    ),
  },
  {
    action: "h2",
    title: "Heading 2",
    svg: svgIcon(
      `<path d="M3 3v10"/>` +
      `<path d="M8 3v10"/>` +
      `<path d="M3 8h5"/>` +
      `<path d="M11 6c0-1 .9-1.8 2-1.8s2 .8 2 1.8c0 .8-.5 1.3-1.2 1.9L11 12.5h4" stroke-width="1.4"/>`,
      "1.7",
    ),
  },
  {
    action: "h3",
    title: "Heading 3",
    svg: svgIcon(
      `<path d="M3 3v10"/>` +
      `<path d="M8 3v10"/>` +
      `<path d="M3 8h5"/>` +
      `<path d="M11 5.5c.4-.8 1.2-1.3 2-1.3 1.1 0 2 .7 2 1.7 0 .9-.7 1.6-1.7 1.7 1.2 0 2.1.8 2.1 1.9 0 1.2-1.1 2.1-2.4 2.1-1 0-1.9-.5-2.3-1.3" stroke-width="1.4"/>`,
      "1.7",
    ),
  },
  {
    action: "list",
    title: "Bullet List",
    svg: svgIcon(
      `<circle cx="3.2" cy="4" r="1" fill="currentColor" stroke="none"/>` +
      `<circle cx="3.2" cy="8" r="1" fill="currentColor" stroke="none"/>` +
      `<circle cx="3.2" cy="12" r="1" fill="currentColor" stroke="none"/>` +
      `<path d="M6.5 4h7.5"/>` +
      `<path d="M6.5 8h7.5"/>` +
      `<path d="M6.5 12h7.5"/>`,
    ),
  },
  {
    action: "olist",
    title: "Numbered List",
    svg: svgIcon(
      `<path d="M2 5V3l-.7.5" stroke-width="1.3"/>` +
      `<path d="M1.5 8.5c0-.6.5-1 1-1s1 .4 1 1c0 .8-2 1.4-2 2.5h2" stroke-width="1.3"/>` +
      `<path d="M6.5 4h7.5"/>` +
      `<path d="M6.5 8h7.5"/>` +
      `<path d="M6.5 12h7.5"/>`,
    ),
  },
  {
    action: "quote",
    title: "Blockquote",
    svg: svgIcon(
      `<path d="M3 10c0-3 1.5-4.5 3-5"/>` +
      `<path d="M3 10c0 1.5 1 2.5 2.2 2.5S7.5 11.5 7.5 10c0-1.4-1.1-2.4-2.3-2.4-.7 0-1.2.2-1.2.2" fill="currentColor" stroke="none"/>` +
      `<path d="M9 10c0-3 1.5-4.5 3-5"/>` +
      `<path d="M9 10c0 1.5 1 2.5 2.2 2.5s2.3-1 2.3-2.5c0-1.4-1.1-2.4-2.3-2.4-.7 0-1.2.2-1.2.2" fill="currentColor" stroke="none"/>`,
      "1.4",
    ),
  },
]

const ACTION_COMMANDS = {
  bold:   (ed) => ed.chain().focus().toggleBold().run(),
  italic: (ed) => ed.chain().focus().toggleItalic().run(),
  h2:     (ed) => ed.chain().focus().toggleHeading({ level: 2 }).run(),
  h3:     (ed) => ed.chain().focus().toggleHeading({ level: 3 }).run(),
  list:   (ed) => ed.chain().focus().toggleBulletList().run(),
  olist:  (ed) => ed.chain().focus().toggleOrderedList().run(),
  quote:  (ed) => ed.chain().focus().toggleBlockquote().run(),
}

const ACTIVE_CHECKS = {
  bold:   (ed) => ed.isActive("bold"),
  italic: (ed) => ed.isActive("italic"),
  h2:     (ed) => ed.isActive("heading", { level: 2 }),
  h3:     (ed) => ed.isActive("heading", { level: 3 }),
  list:   (ed) => ed.isActive("bulletList"),
  olist:  (ed) => ed.isActive("orderedList"),
  quote:  (ed) => ed.isActive("blockquote"),
}

const TiptapEditor = {
  mounted() {
    this._toolbar = this._buildToolbar()
    this._proseMirrorEl = document.createElement("div")
    this._proseMirrorEl.className = "tiptap-prosemirror"
    this._hiddenInput = document.createElement("input")
    this._hiddenInput.type = "hidden"
    this._hiddenInput.name = this.el.dataset.fieldName || "content"
    this.el.appendChild(this._toolbar)
    this.el.appendChild(this._proseMirrorEl)
    this.el.appendChild(this._hiddenInput)
    this._editor = this._initEditor()
  },

  destroyed() {
    if (this._editor) this._editor.destroy()
  },

  _buildToolbar() {
    const toolbar = document.createElement("div")
    toolbar.className = "tiptap-toolbar"
    TOOLBAR_BTNS.forEach(({ action, title, svg }) => {
      const btn = document.createElement("button")
      btn.type = "button"
      btn.dataset.action = action
      btn.title = title
      btn.innerHTML = svg
      toolbar.appendChild(btn)
    })
    toolbar.addEventListener("mousedown", (e) => {
      const btn = e.target.closest("button[data-action]")
      if (!btn) return
      e.preventDefault()
      this._handleToolbarClick(btn)
    })
    return toolbar
  },

  _handleToolbarClick(btn) {
    this._runAction(btn.dataset.action)
  },

  _initEditor() {
    const initial = this.el.dataset.initial || ""
    const ed = new Editor({
      element: this._proseMirrorEl,
      extensions: [
        StarterKit.configure({ heading: { levels: [2, 3] } }),
        Markdown.configure({ html: false }),
        Placeholder.configure({ placeholder: "Write something…" }),
      ],
      content: initial,
      onUpdate: ({ editor }) => this._onUpdate(editor),
      onSelectionUpdate: ({ editor }) => this._updateActiveStates(editor),
    })
    this._hiddenInput.value = initial
    return ed
  },

  _onUpdate(editor) {
    // prosemirror-markdown escapes all square brackets, which breaks footnote
    // syntax ([^1] → \[^1\]). Restore it: [^ is exclusively footnote syntax
    // in Earmark so this replacement is unambiguous.
    const md = editor.storage.markdown.getMarkdown()
      .replace(/\\\[(\^[^\]]+)\\\]/g, "[$1]")
    this._hiddenInput.value = md
    this._hiddenInput.dispatchEvent(new Event("input", { bubbles: true }))
  },

  _runAction(action) {
    const cmd = ACTION_COMMANDS[action]
    if (!cmd) return
    cmd(this._editor)
    this._updateActiveStates(this._editor)
  },

  _updateActiveStates(editor) {
    const btns = this._toolbar.querySelectorAll("button[data-action]")
    btns.forEach((btn) => {
      const check = ACTIVE_CHECKS[btn.dataset.action]
      if (!check) return
      btn.classList.toggle("is-active", check(editor))
    })
  },

}

// ─── Tag search keyboard handling ─────────────────────────────────────────────
//
// Hook lives on the wrapper div (not the input) so it owns the dropdown too.
// MutationObserver resets the highlight to index 0 whenever the dropdown's
// children change (new suggestions or closed). Style mutations don't trigger
// childList observers, so _applyHighlight() never causes a loop.

const TagSearch = {
  mounted() {
    this.highlightedIndex = -1
    this._input = this.el.querySelector("input[name='tag_search']")

    this._observer = new MutationObserver(() => {
      const options = this._getOptions()
      this.highlightedIndex = options.length > 0 ? 0 : -1
      this._applyHighlight(options)
    })
    this._observer.observe(this.el, { childList: true, subtree: true })

    this._input.addEventListener("keydown", (e) => {
      const options = this._getOptions()
      if (e.key === "ArrowDown") {
        e.preventDefault()
        if (options.length === 0) return
        this.highlightedIndex =
          this.highlightedIndex < options.length - 1 ? this.highlightedIndex + 1 : 0
        this._applyHighlight(options)
      } else if (e.key === "ArrowUp") {
        e.preventDefault()
        if (options.length === 0) return
        this.highlightedIndex =
          this.highlightedIndex <= 0 ? options.length - 1 : this.highlightedIndex - 1
        this._applyHighlight(options)
      } else if (e.key === "Enter") {
        e.preventDefault()
        const idx = this.highlightedIndex >= 0 ? this.highlightedIndex : 0
        const target = options[idx]
        if (target) target.click()
      }
    })
  },

  destroyed() {
    if (this._observer) this._observer.disconnect()
  },

  _getOptions() {
    return Array.from(this.el.querySelectorAll("ul button"))
  },

  _applyHighlight(options) {
    options.forEach((btn, i) => {
      btn.style.background = i === this.highlightedIndex ? "var(--bg-alt)" : "none"
    })
  },
}

// ─── Theme toggle ──────────────────────────────────────────────────────────────

const ThemeToggle = {
  mounted() {
    this.el.addEventListener("click", () => {
      const html = document.documentElement
      const isDark = html.classList.toggle("qm-dark")
      localStorage.setItem("theme", isDark ? "dark" : "light")
      window.dispatchEvent(new CustomEvent("qm-theme-flip"))
    })
  },
}

export default { TiptapEditor, TagSearch, ThemeToggle }
