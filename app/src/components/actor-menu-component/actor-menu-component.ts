import { Component } from '@angular/core';

@Component({
  selector: 'actor-menu',
  standalone: false,
  templateUrl: './actor-menu-component.html',
  styleUrl: './actor-menu-component.scss',
})
export class ActorMenuComponent {
  protected handleMenuItemClick(item: any) {
    console.log("actor menu:", item);
  }
}
