module EmailsHelper
	def safe_filename(uploaded_file)
    original = uploaded_file.original_filename
    ext = File.extname(original)
    base = File.basename(original, ext)
    safe_base = base.gsub(/[^a-zA-Z0-9_-]/, "_")
    "#{safe_base}_#{SecureRandom.hex(8)}#{ext}"
  end
end
