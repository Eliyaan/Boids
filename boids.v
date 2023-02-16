//Detection d'attirance à l'autre coté

module main
import gg
import gx
import rand as rd
import math as m

const (
    win_width    = 600
    win_height   = 600
    bg_color     = gx.white
    nb_boids = 500
    boid_size = 2
    speed = 3
    detect_radius = 20
    pow_detec_radius = detect_radius*detect_radius
    pow_trop_pres = 3*3
)

[heap]
struct Boid{
    mut:
    x int
    y int
    dir_x f64
    dir_y f64
}


struct App {
mut:
    gg    &gg.Context = unsafe { nil }
	boids []Boid
    opti_list [][][]&Boid = [][][]&Boid{len:win_width/detect_radius, init:[][]&Boid{len:win_height/detect_radius, init:[]&Boid{cap:10}}}
}



fn main() {
    mut app := &App{
        gg: 0
    }
    app.gg = gg.new_context(
        width: win_width
        height: win_height
        create_window: true
        window_title: '- Boids -'
        user_data: app
        bg_color: bg_color
        frame_fn: on_frame
    )
    for _ in 0..nb_boids{
        app.boids << Boid{rd.int_in_range(0, win_width)!, rd.int_in_range(0, win_height)!, rd.f64_in_range(-1.0, 1.0)!, rd.f64_in_range(-1.0, 1.0)!}
    }
    //lancement du programme/de la fenêtre
    app.gg.run()
}

fn on_frame(mut app App) {
    //Draw
    app.gg.begin()
    for mut boid in app.boids{
        mut boids_trop := []Boid{}
        mut boids_normal := []Boid{}
        //store to the right list
        if boid.x >= win_width{
            boid.x -= win_width
        }else if boid.x < 0{
            boid.x += win_width
        }
        if boid.y >= win_height{
            boid.y -= win_height
        }else if boid.y < 0{
            boid.y += win_height
        }
        i := int(boid.x/detect_radius)
        j := int(boid.y/detect_radius)
        app.opti_list[i][j] << &boid

        for l in -1..2{
            for c in -1..2{
                if i + l >= 0 && i + l < win_width/detect_radius && j + c >= 0 && j + c < win_height/detect_radius{
                    for other in app.opti_list[i+l][j+c]{
                        dist := m.pow(m.abs(boid.x - other.x),2)+m.pow(m.abs(boid.y - other.y),2)
                        if dist < pow_detec_radius{
                            if dist < pow_trop_pres{
                                boids_trop << other
                            }else{
                                boids_normal << other
                            }
                        }
                    }
                }
            }
        }
        nb_near := boids_trop.len + boids_normal.len
        // COHESION
        mut moy_coord_x := 0.0
        mut moy_coord_y := 0.0
        // SEPARATION
        mut moy_separation_x := 0.0
        mut moy_separation_y := 0.0
        for other in boids_trop{
            moy_coord_x += other.x
            moy_coord_y += other.y
            moy_separation_x += moy_coord_x - boid.x
            moy_separation_y += moy_coord_y - boid.y
        }
        for other in boids_normal{
            moy_coord_x += other.x
            moy_coord_y += other.y
        }
        moy_coord_x /= nb_near
        moy_coord_y /= nb_near
        boid.dir_x = moy_coord_x - boid.x
        boid.dir_y = moy_coord_y - boid.y
        // SEPARATION
        boid.dir_x +=
        boid.dir_y +=





        //Apply vector
        //Need normalisation
        boid.x += int(boid.dir_x*speed)
        boid.y += int(boid.dir_y*speed)

        //draw
        mut color := u8(64)
        if nb_near > 191{
            color = 255
        }else{
            color += u8(nb_near)
        }
        
        app.gg.draw_circle_filled(boid.x, boid.y, boid_size, gx.Color{color, 10, 10, 255})
    }
    app.gg.end()
}