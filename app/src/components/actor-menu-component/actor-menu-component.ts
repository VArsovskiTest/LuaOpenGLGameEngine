import { AfterViewInit, Component, inject } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { ActorBehavior } from '../../models/miscelaneous.models';

@Component({
  selector: 'actor-menu',
  standalone: false,
  templateUrl: './actor-menu-component.html',
  styleUrl: './actor-menu-component.scss',
})
export class ActorMenuComponent implements AfterViewInit {
  private fb: FormBuilder = inject(FormBuilder);
  protected actorBehaviorsList: ActorBehavior[][] = [];
  protected formDataControls: FormGroup = this.fb.group({
    actorControl: ['', Validators.required]
  });

  protected formDataBehaviors: FormGroup = this.fb.group({
    actorBehaviors: [[]]
  });

  ngAfterViewInit(): void {
    this.actorBehaviorsList.push([{id: 0, name: "Movable"}, {id: 0, name: "Destructible"}]);
    this.actorBehaviorsList.push([{id: 0, name: "Aggressive"}, {id: 1, name: "Balanced"}, {id: 2, name: "Tactical"}, {id: 3, name: "Tentative"}]);
  }

  protected handleMenuItemClick(item: any) {}
}
