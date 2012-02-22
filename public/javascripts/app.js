var App = App || {};

App.pusher = new Pusher('35e98fc9d7c113c3ba1d');
App.channel = App.pusher.subscribe('messages');
App.presenceChannel = App.pusher.subscribe('presence-messages');

App.addMessage = function(data) {
  var html = ich.message(data);
  $('#messages').prepend(html);
};

App.channel.bind('create', function(data) {
  console.log(data);
  if (data.user_id !== App.currentUserId) {
    App.addMessage(data);
  }
});

App.presenceChannel.bind('pusher:subscription_succeeded', function(members){
  members.each(function(member){
    var el = $('<li>').text(member.info.nickname).attr('data-attribute-id', member.id);
    $('#roster').append(el);
  });
});

App.presenceChannel.bind('pusher:member_added', function(data) {
  var el = $('<li>').text(data.info.nickname).attr('data-attribute-id', data.id);
  App.rosterEl().append(el);
});

App.presenceChannel.bind('pusher:member_removed', function(data) {
  App.rosterEl().find('li[data-attribute-id=' + data.id + ']').remove();
});

App.rosterEl = function(){
  return $('#roster');
};


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

App.buttonEl = function(){
  return $('#create_message button');
};

$(function(){
  (function(a){
    $('a.logout').click(function(e){
      e.preventDefault();
      $.ajax({
        url: this.href,
        type: 'POST',
        data: { '_method': 'DELETE' },
        success: function(data){
          window.location = "/login";
        }
      });
    });

    $('form#create_message').submit(function(e){
      var nickname = a.currentNickname(),
      content = a.currentContent();

      e.preventDefault();

      a.buttonEl().button('loading');

      if (content !== '') {
        $.ajax({
          url: this.action,
          type: 'post',
          dataType: 'json',
          contentType: 'application/json',
          data: JSON.stringify({ content: content }),
          success: function(data) {
            a.addMessage(data.message);
            a.contentEl().val('');
            a.buttonEl().button('reset');
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
