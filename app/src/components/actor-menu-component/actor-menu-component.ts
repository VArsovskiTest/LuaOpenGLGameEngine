import { AfterViewInit, Component, EventEmitter, inject, Input, OnInit, Output } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { ActorBehavior } from '../../models/miscelaneous.models';
import { BehaviorSubject, Observable } from 'rxjs';

@Component({
  selector: 'actor-menu',
  standalone: false,
  templateUrl: './actor-menu-component.html',
  styleUrl: './actor-menu-component.scss',
})
export class ActorMenuComponent implements AfterViewInit {
  
  @Input() incomingColor$: Observable<string> = new Observable();
  @Input() showActorMenu$: Observable<boolean> = new Observable();
  @Input() showStageMenu$: Observable<boolean> = new Observable();
  @Output() selectedColorChanged: EventEmitter<string | null> = new EventEmitter();
  // @ViewChild('selectedColorContainer') selectedColorContainer!: ElementRef;

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

  onColorChange(color: string) {
    console.log("Color-Picker: emitting color: ", color)
    this.selectedColorChanged.emit(color);
  }

  protected handleMenuItemClick(item: any) {}
}
