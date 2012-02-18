var App = App || {};

App.pusher = new Pusher('35e98fc9d7c113c3ba1d');
App.channel = App.pusher.subscribe('messages');

App.addMessage = function(data) {
  var html = ich.message(data);
  $('#messages').prepend(html);
};

App.channel.bind('create', function(data) {
  console.log(data);
  if (data.user_ref !== App.userRef) {
    App.addMessage(data);
  }
});

App.nicknameEl = function(){
  return $('input[name=nickname]');
};

App.currentNickname = function(){
  return this.nicknameEl().val();
};

App.contentEl = function(){
  return $('textarea[name=content]');
};

App.currentContent = function(){
  return this.contentEl().val();
};

$(function(){
  (function(a){
    $('form#create_message').submit(function(e){
      var nickname = a.currentNickname(),
      content = a.currentContent();

      e.preventDefault();

      if (nickname !== '' && content !== '') {
        $.ajax({
          url: this.action,
          type: 'post',
          dataType: 'json',
          contentType: 'application/json',
          data: JSON.stringify({ nickname: nickname, content: content, user_ref: a.userRef }),
          success: function(data) {
            a.addMessage(data.message);
            a.contentEl().val('');
          }
        });
      }
    });

    $(a.contentEl()).keydown(function(e){
      if (e.keyCode === 13) {
        e.preventDefault();
        $(this).closest('form').submit();
      }
    });
  }(App));
});
