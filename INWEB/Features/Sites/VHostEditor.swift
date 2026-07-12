import SwiftUI

/// Modal editor for adding or editing a single virtual host.
/// Handed a closure so the parent can decide how to persist the payload.
struct VHostEditor: View {

    let existing: Vhost?
    let onSave: (VHostPayload) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name  = ""
    @State private var label = ""
    @State private var root  = ""
    @State private var phpAuto = true
    @State private var enabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Domain") {
                    TextField("wordpress.local", text: $name)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .font(.system(.body, design: .monospaced))
                }
                Section("Friendly label (optional)") {
                    TextField("My blog", text: $label)
                }
                Section("Document root") {
                    TextField("/sdcard/…/www/site", text: $root)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(.system(.caption, design: .monospaced))
                }
                Section("PHP handling") {
                    Toggle("Serve .php via PHP-FPM", isOn: $phpAuto)
                }
                Section {
                    Toggle("Enabled", isOn: $enabled)
                }
            }
            .navigationTitle(existing == nil ? "New site" : "Edit site")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(VHostPayload(
                            id: existing?.id,
                            serverName: name.trimmingCharacters(in: .whitespaces),
                            documentRoot: root.trimmingCharacters(in: .whitespaces),
                            phpMode: phpAuto ? "AUTO" : "STATIC",
                            enabled: enabled,
                            label: label
                        ))
                        dismiss()
                    }
                    .disabled(name.isEmpty || root.isEmpty)
                }
            }
            .onAppear {
                if let e = existing {
                    name   = e.serverName
                    label  = e.label
                    root   = e.documentRoot
                    phpAuto = (e.phpMode.uppercased() == "AUTO")
                    enabled = e.enabled
                }
            }
        }
    }
}
