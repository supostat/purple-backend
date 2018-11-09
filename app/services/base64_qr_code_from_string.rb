require "barby"
require "barby/barcode"
require "barby/barcode/qr_code"
require "barby/outputter/png_outputter"

class Base64QrCodeFromString
  def self.call(string:)
    qrcode = Barby::QrCode.new(string)
    base64_output = Base64.encode64(qrcode.to_png({ xdim: 6 }))
    base64_png = "data:image/png;base64,#{base64_output}"
  end
end
