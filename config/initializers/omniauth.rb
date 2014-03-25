OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '213640202163880', '07a19ab760466d7eb0eebd3950bcb39f', {scope: "publish_actions, publish_stream, photo_upload, manage_pages, video_upload"}
end