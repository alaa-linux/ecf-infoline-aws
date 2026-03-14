import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  message = 'Chargement...';

  ngOnInit(): void {
    fetch('http://a8fbedb3d3a604a1ba5aed3443ee9fa0-1676681405.eu-west-3.elb.amazonaws.com/hello')
      .then(response => response.text())
      .then(data => {
        this.message = data;
      })
      .catch(error => {
        console.error(error);
        this.message = 'Erreur lors de l’appel API';
      });
  }
}
