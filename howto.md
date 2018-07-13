# Siema!

![Protip](https://i1.jbzdy.pl/contents/2018/07/4a8805124e53c9f0e76b31f4743331bf.jpg)

# Cele na dziś:
1. Dowiedzieć się jaki JS mamy już w naszych apkach.
2. AJAX (Asynchronous JavaScript and XML). Zrobimy kilka dynamicznych zapytań do backendu.
3. Na co uważać?

# 1. JS który już macie w swoich apkach:
## Zajrzyjmy w nasz [Gemfile](Gemfile).
- turbolinks ❗
- coffee-rails
- uglifier

## A co się kryje w [application layout](app/views/layouts/application.html.erb)?
- `javascript_include_tag`

## Pliki manifestu
- [JS](app/assets/javascripts/application.js)

## Ruby on Rails unobtrusive JavaScript (rails-ujs) ❗
- `link_to` (`method`, `confirm`, `disable_with`, `remote`) [(przykład)](app/views/authors/index.html.erb)
- `form_for` (`remote`)
- `form_with`

# 2. Ruszamy w świat JSa
![meme z Kubą](https://memy.binarapps.com/memes/t7-V1efOnGjEqouJdogu.jpg)

## Wrzućmy sobie jQuery

```html
<script
  src="https://code.jquery.com/jquery-3.3.1.min.js"
  integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
  crossorigin="anonymous"></script>
```

## Pierwszy sposób na AJAX: renderowanie widoków `.js.erb`
1. Sprawmy by nasz formularz/link był asychroniczny

Dodaj opcję `remote: true` do `form_for` lub `link_to`.
Alternatywnie używaj `form_with`, który domyślnie jest asynchroniczny
```ruby
form_for @model, remote: true
link_to cats_and_dogs_path, remote: true
form_with model: @model
```

2. Upewnijmy się co do formatu

Jeśli nasza akcja kontrollera odpowiada na więcej niż jeden format (html, json, js, pdf) musimy zaznaczyć z którego chcemy korzystać w formularzu/linku.

Jeśli odpowiada tylko na js i tak dobrą praktyką jest zaznaczenie, że jednak ten format wybieramy.

Dodajemy `format: :js` do `form_for`, `from_with`, `*_path`
```ruby
form_for @model, remote: true, format: :js
link_to cats_and_dogs_path(format: :js), remote: true
form_with model: @model, format: :js
```

3. Robimy widok `.js.erb`

Akcja w kontrollerze. Stwórz instacje. Spróbuj zapisać.
```ruby
def create
  @author = Author.create(author_params)
end
```
Widok `app/views/authors/create.js.erb`:
```erb
<% if @author.persisted? %>
  $('.authors').append('<%= j render('author', author: @author) %>');
<% else %>
  alert('<%= j @author.errors.full_messages.join(', ') %>');
<% end %>
```

## Drugi sposób na AJAX: nasłuchiwanie na eventy
1. Akcja odpowiada formatem html lub json.
```ruby
def create
  @author = Author.create(author_params)

  respond_to do |format|
    format.js
    format.html { render partial: 'authors/author', locals: { author: @author } }
    format.json { render json: @author }
  end
end
```

2. Nasłuchujemy na wydarzenia typu `ajax` i regaujemy (w tym przykładzie na html).
`app/assets/javascripts/author-form.js`:
```js
$('.new-author-form')
  .on('ajax:success', function(event) {
    const [data, status, xhr] = event.detail;
    $('.authors').append(xhr.responseText);
  })
  .on('ajax:error', function(event) {
    const [data, status, xhr] = event.detail;

    $('.error-box').append('<img src="https://bit.ly/2ugW2Jb">')
  });
```

# 3. Na co uważać? Jak żyć?

## Czekaj
Uruchomiony skrypt JS będzie pracował na aktualnej wersji dokumentu.
Jeśli chcesz poczekać na załadowanie dokumentu przed uruchomieniem skryptu musisz nasłuchiwać na zdarzenie załadowania.

Zwykle z wykorzystaniem jQuery robi się to przez:
```js
$(document).ready(function(){
  // tu kod który ma się wykonać po pełnym załadowaniu strony
});
// lub krócej
$(function(){
  // tu kod który ma się wykonać po pełnym załadowaniu strony
});
```

Ale ze względu na to, że mamy turbolink może to nie działać tak jak tego oczekujemy. Turbolinki mają swój event oznaczający załadowanie nowej strony:

```js
$(document).on("turbolinks:load", function() {
  // tu kod który ma się wykonać po pełnym załadowaniu strony
})
```
[więcej na ten temat](https://github.com/turbolinks/turbolinks#observing-navigation-events)

## Miej świadomość zmian
Gdy wykorzystujemy selektor do przycisków i podpiany akcje np. `$('button').click(sayHello)` to należy być świadomym, że dana akcje jest podpięta tylko pod istniejące przyciski. Jeśli jakieś przyciski pojawią później (zostaną dodane przez inny skrypt lub AJAX) to nie będą one reagowały na tą akcję.

## Korzystaj z delegacji
Większość eventów jest delegowana w górę drzewa, więc zamiast ustawiać nasłuchiwanie na wydarzenie na danym elemencie, można ustawić go na jednym z jego przodków i filtrować selektorem.
```js
$('.some-class').on('click', function(event) { /*...*/ });
//
$(document).on('click', '.some-class', function(event) { /*...*/ });
```
[więcej na ten temat](https://learn.jquery.com/events/event-delegation/)


# Coś do poklikania:
* [Rails Guide na temat JS w Railsach](http://guides.rubyonrails.org/working_with_javascript_in_rails.html)
* [Akcje odpowiadające na różne formaty z `respond_to`](https://apidock.com/rails/ActionController/MimeResponds/InstanceMethods/respond_to)
* [Co to za `j` lub `escape_javascript` przed `render`?](http://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html#method-i-escape_javascript)
* [Dokumentacja jQuery](https://api.jquery.com/) (polecam korzystać z lewej kolumny gdzie są odnośniki do różnych akcji które możesz chcieć wykonać. Search też tu działa całkiem dobrze 😀 )
* [Dokumentacja Turbolinks](https://github.com/turbolinks/turbolinks)
* [Obrazek, który kazali mi wstawić do prezentacji](https://www.wykop.pl/cdn/c3201142/comment_vIlhvVLg3E9sz9lCnYSK9OWfKfUWIy0Z,w400.jpg)
* [Piątek i Dzień frytek](https://www.pugelton.com/wp-content/uploads/2017/11/friday-small.jpg)

# Miłego kodowania :)

![Thanks!](https://gif-finder.com/wp-content/uploads/2016/09/Anthony-Hopkins-Thank-You.gif)
