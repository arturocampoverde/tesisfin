/*
  Proto!TextboxList + Autocomplete 0.1
  - Prototype version required: 6.0
  
  Credits:
  - Idea: Facebook
  - Guillermo Rauch: Original MooTools script
  
  Changelog:
  - 0.1: translation of MooTools script
*/

/* Copyright: InteRiders <http://interiders.com/> - Distributed under MIT - Keep this message! */

var FacebookList = Class.create(TextboxList, { 
  
  loptions: $H({    
    autocomplete: {
      'opacity': 0.8,
      'maxresults': 10,
      'minchars': 1
    }
  }),
  
  initialize: function($super,element, autoholder, options) {
    $super(element, options);
    this.data = [];
		this.autoholder = $(autoholder).setOpacity(this.loptions.get('autocomplete').opacity);
		this.autoresults = this.autoholder.select('ul').first();
		var children = this.autoresults.select('li');
    children.each(function(el) { this.add(el.innerHTML); }, this); 
  },
  
  autoShow: function(search) {
    this.autoholder.setStyle({'display': 'block'});
    this.autoholder.descendants().each(function(e) { e.setStyle({'display': 'none'}) });
    if(! search || ! search.strip() || (! search.length || search.length < this.loptions.get('autocomplete').minchars)) 
    {
      this.autoholder.select('.default').first().setStyle({'display': 'block'});
      this.resultsshown = false;
    } else {
      this.resultsshown = true;
      this.autoresults.setStyle({'display': 'block'}).update('');
      this.data.filter(function(str) { return str ? new RegExp(search,'i').test(str) : false; }).each(function(result, ti) {
        if(ti >= this.loptions.get('autocomplete').maxresults) return;
        var that = this;
        var el = new Element('li').update(this.autoHighlight(result, search));
        el.observe('mouseover',function() { 
            that.autoFocus(this); 
        });
        el.observe('click',function(e) { 
            Event.stop(e);
            that.autoAdd(this); 
        });
        this.autoresults.insert(el);
        el.cacheData('result', result,1);
        if(ti == 0) this.autoFocus(el);
      }, this);
    }
    return this;
  },
  
  autoHighlight: function(html, highlight) {
    return html.gsub(new RegExp(highlight,'i'), function(match) {
      return '<em>' + match[0] + '</em>';
    });
  },
  
  autoHide: function() {    
    this.resultsshown = false;
    this.autoholder.setStyle({'display': 'none'});    
    return this;
  },
  
  autoFocus: function(el) {
    if(! el) return;
    if(this.autocurrent) this.autocurrent.removeClassName('auto-focus');
    this.autocurrent = el.addClassName('auto-focus');
    return this;
  },
  
  autoMove: function(direction) {    
    if(!this.resultsshown) return;
    this.autoFocus(this.autocurrent[(direction == 'up' ? 'previous' : 'next')]());
    return this;
  },
  
  autoFeed: function(text) {
    if (this.data.indexOf(text) == -1)
        this.data.push(text);
    return this;
  },
  
  autoAdd: function(el) {
    if(!el || ! el.retrieveData('result')) return;
    this.add(el.retrieveData('result'));
    delete this.data[this.data.indexOf(el.retrieveData('result'))];
    this.autoHide();
    var input = this.lastinput || this.current.retrieveData('input');
    input.clear().focus();
    return this;
  },
  
  createInput: function($super,options) {
    var li = $super(options);
    var input = li.retrieveData('input');
    input.observe('keydown', function(e) {
        this.dosearch = false;
        switch(e.keyCode) {
          case Event.KEY_UP: return this.autoMove('up');
          case Event.KEY_DOWN: return this.autoMove('down');        
          case Event.KEY_RETURN:
            if(! this.autocurrent) break;
            this.autoAdd(this.autocurrent);
            this.autocurrent = false;
            this.autoenter = true;
            break;
          case Event.KEY_ESC: 
            this.autoHide();
            if(this.current && this.current.retrieveData('input'))
              this.current.retrieveData('input').clear();
            break;
          default: this.dosearch = true;
        }
    }.bind(this));
    input.observe('keyup',function() {
        if(this.dosearch) this.autoShow(input.value);
    }.bind(this));
    input.observe(Prototype.Browser.IE ? 'keydown' : 'keypress', function(e) { 
      if(this.autoenter) Event.stop(e);
      this.autoenter = false;
    }.bind(this));
    return li;
  },
  
  createBox: function($super,text, options) {
    var li = $super(text, options);
    li.observe('mouseover',function() { 
        this.addClassName('bit-hover');
    });
    li.observe('mouseout',function() { 
        this.removeClassName('bit-hover') 
    });
    var a = new Element('a', {
      'href': '#',
      'class': 'closebutton'
      }
    );
    a.observe('click',function(e) {
          Event.stop(e);
          if(! this.current) this.focus(this.maininput);
          this.dispose(li);
    }.bind(this));
    li.insert(a).cacheData('text', text);
    return li;
  }
  
});

document.observe('dom:loaded', function() {
  // init
  tlist2 = new FacebookList('facebook-demo', 'facebook-auto');
  
  // fetch and feed
  new Ajax.Request('json.html', {
    onSuccess: function(transport) {
        transport.responseText.evalJSON(true).each(function(t){tlist2.autoFeed(t)});
    }
  });
});

Element.addMethods({
    onBoxDispose: function(item,obj) { obj.autoFeed(item.retrieveData('text')); },
    onInputFocus: function(el,obj) { obj.autoShow(); },    
    onInputBlur: function(el,obj) { 
      obj.lastinput = el;
      obj.blurhide = obj.autoHide.bind(obj).delay(0.1);
    },
    filter:function(D,E){var C=[];for(var B=0,A=this.length;B<A;B++){if(D.call(E,this[B],B,this)){C.push(this[B]);}}return C;}
});  





