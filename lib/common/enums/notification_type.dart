enum NotificationType{order, message, general, wallet}

NotificationType? getNotificationTypeEnum(String? type){
  switch(type){
    case 'order':
      return NotificationType.order;
    case 'message':
      return NotificationType.message;
    case 'general':
      return NotificationType.general;
    case 'wallet':
      return NotificationType.wallet;
  }
  return null;
}