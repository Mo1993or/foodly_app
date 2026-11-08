import 'dart:ui';

const apiUrl = "https://foodlyapi-production-3d30.up.railway.app/api/v1";
const apiUrlPayment = "https://pay.wave.com/m/M_sn_snCiyi6_rFbh/c/sn/";

extension HexColor on String {
  Color toColor() {
    final buffer = StringBuffer();
    if (this.length == 6 || this.length == 7) buffer.write('ff');
    buffer.write(this.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
