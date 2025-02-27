class ErrorSerializer
  def self.format_error(e, status)
    {
      message: e.message,
      errors: [status]
    }
  end
end
