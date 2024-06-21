import { HttpClient } from '@angular/common/http';
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  title = 'clientapp';
  response: string = '';

  constructor(private httpClient: HttpClient) {}

  ngOnInit() {
    this.httpClient.get('WeatherForecast').subscribe((res) => {
      console.log(res);
      this.response = JSON.stringify(res);
    });
  }
}
