String getFirstThreeCharacters(String str) {
  return str.substring(0, 3);
}

String getAvatarTitle(String str) {
  final split = str.split(' ');
  if (split.length > 1) {
    return '${split[0][0].toUpperCase()}${split[1][0].toUpperCase()}';
  } else {
    return str[0].toUpperCase();
  }
}
